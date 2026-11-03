//
//  GetNutritionAnalyticsUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Coordinates period-based aggregation of real SwiftData meal records for
//  caloric trends, macronutrient distributions, goal comparisons, and explainable insights.
//

import Foundation

public protocol GetNutritionAnalyticsUseCaseProtocol: Sendable {
    func execute(
        periodType: AnalyticsPeriodType,
        anchorDate: Date,
        calendar: Calendar
    ) async throws -> PeriodAnalyticsData
}

public final class GetNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    public init(mealRepository: MealRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.mealRepository = mealRepository
        self.userRepository = userRepository
    }

    public func execute(
        periodType: AnalyticsPeriodType,
        anchorDate: Date,
        calendar: Calendar = Calendar.current
    ) async throws -> PeriodAnalyticsData {
        let profile = (try? await userRepository.getUserProfile()) ?? UserProfile()

        // 1. Calculate Period Boundaries
        let (startDate, endDate, formattedTitle, previousStart, previousEnd) = computePeriodBounds(
            for: periodType,
            anchorDate: anchorDate,
            calendar: calendar
        )

        // 2. Fetch Meals for the Active Period
        let currentMeals = try await mealRepository.fetchMeals(from: startDate, to: endDate)

        // 3. Fetch Meals for Previous Period (for comparative analytics)
        let previousMeals = try await mealRepository.fetchMeals(from: previousStart, to: previousEnd)
        let previousTotalCalories = previousMeals.isEmpty ? nil : previousMeals.reduce(0) { $0 + $1.totalCalories }

        // 4. Compute Time-Series Daily Points
        let dailyPoints = computeDailyPoints(
            periodType: periodType,
            startDate: startDate,
            endDate: endDate,
            meals: currentMeals,
            targetCalories: profile.dailyCalorieTarget,
            calendar: calendar
        )

        let recordedDays = dailyPoints.filter { $0.hasRecords }.count
        let totalDays = dailyPoints.count

        // 5. Aggregate Nutrition Totals
        let totalCalories = currentMeals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = currentMeals.reduce(0) { $0 + $1.totalProteinGrams }
        let totalCarbs = currentMeals.reduce(0) { $0 + $1.totalCarbGrams }
        let totalFat = currentMeals.reduce(0) { $0 + $1.totalFatGrams }
        let totalFiber = currentMeals.reduce(0) { $0 + $1.totalFiberGrams }

        // Daily average based on recorded days (avoiding division by zero if no records)
        let divisor = max(1, Double(recordedDays > 0 ? recordedDays : totalDays))
        let dailyAverageCalories = totalCalories / divisor
        let dailyAverageProtein = totalProtein / divisor
        let dailyAverageCarbs = totalCarbs / divisor
        let dailyAverageFat = totalFat / divisor
        let dailyAverageFiber = totalFiber / divisor

        // Comparative change
        var calorieChangePercentage: Double? = nil
        if let prevCal = previousTotalCalories, prevCal > 0 {
            calorieChangePercentage = ((totalCalories - prevCal) / prevCal) * 100.0
        }

        // 6. Category Breakdown
        let categoryBreakdown = computeCategoryBreakdown(meals: currentMeals, totalCalories: totalCalories)

        // 7. Macronutrient Distribution
        let macroDistribution = MacroDistribution(
            proteinGrams: totalProtein,
            carbGrams: totalCarbs,
            fatGrams: totalFat,
            fiberGrams: totalFiber
        )

        // 8. Generate Deterministic & Explainable Insights
        let insights = generateInsights(
            periodType: periodType,
            recordedDays: recordedDays,
            totalDays: totalDays,
            dailyAverageCalories: dailyAverageCalories,
            targetCalories: profile.dailyCalorieTarget,
            macroDistribution: macroDistribution,
            dailyAverageFiber: dailyAverageFiber,
            categoryBreakdown: categoryBreakdown,
            hasMeals: !currentMeals.isEmpty
        )

        return PeriodAnalyticsData(
            periodType: periodType,
            startDate: startDate,
            endDate: endDate,
            formattedPeriodTitle: formattedTitle,
            totalCalories: totalCalories,
            dailyAverageCalories: dailyAverageCalories,
            targetCalories: profile.dailyCalorieTarget,
            previousPeriodCalories: previousTotalCalories,
            calorieChangePercentage: calorieChangePercentage,
            dailyPoints: dailyPoints,
            categoryBreakdown: categoryBreakdown,
            macroDistribution: macroDistribution,
            totalProtein: totalProtein,
            targetProtein: profile.dailyProteinTargetGrams,
            dailyAverageProtein: dailyAverageProtein,
            totalCarbs: totalCarbs,
            targetCarbs: profile.dailyCarbTargetGrams,
            dailyAverageCarbs: dailyAverageCarbs,
            totalFat: totalFat,
            targetFat: profile.dailyFatTargetGrams,
            dailyAverageFat: dailyAverageFat,
            totalFiber: totalFiber,
            targetFiber: 30.0,
            dailyAverageFiber: dailyAverageFiber,
            recordedDaysCount: recordedDays,
            totalDaysInPeriod: totalDays,
            insights: insights
        )
    }

    // MARK: - Period Boundaries Helpers

    private func computePeriodBounds(
        for periodType: AnalyticsPeriodType,
        anchorDate: Date,
        calendar: Calendar
    ) -> (start: Date, end: Date, title: String, prevStart: Date, prevEnd: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")

        switch periodType {
        case .day:
            let start = calendar.startOfDay(for: anchorDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)

            formatter.dateFormat = "EEEE, dd/MM/yyyy"
            let title = formatter.string(from: start).capitalized

            let prevStart = calendar.date(byAdding: .day, value: -1, to: start)!
            let prevEnd = calendar.date(byAdding: .day, value: -1, to: end)!
            return (start, end, title, prevStart, prevEnd)

        case .week:
            let interval = calendar.dateInterval(of: .weekOfYear, for: anchorDate) ?? DateInterval(start: anchorDate, duration: 86400 * 7)
            let start = calendar.startOfDay(for: interval.start)
            let end = calendar.date(byAdding: .day, value: 7, to: start)!.addingTimeInterval(-1)

            formatter.dateFormat = "dd/MM"
            let startStr = formatter.string(from: start)
            let endStr = formatter.string(from: end)
            let weekNumber = calendar.component(.weekOfYear, from: start)
            let year = calendar.component(.year, from: start)
            let title = "Tuần \(weekNumber) (\(startStr) – \(endStr), \(year))"

            let prevStart = calendar.date(byAdding: .day, value: -7, to: start)!
            let prevEnd = calendar.date(byAdding: .day, value: -7, to: end)!
            return (start, end, title, prevStart, prevEnd)

        case .month:
            let interval = calendar.dateInterval(of: .month, for: anchorDate) ?? DateInterval(start: anchorDate, duration: 86400 * 30)
            let start = calendar.startOfDay(for: interval.start)
            let end = calendar.date(byAdding: .month, value: 1, to: start)!.addingTimeInterval(-1)

            formatter.dateFormat = "'Tháng' MM, yyyy"
            let title = formatter.string(from: start)

            let prevStart = calendar.date(byAdding: .month, value: -1, to: start)!
            let prevEnd = calendar.date(byAdding: .month, value: -1, to: end)!
            return (start, end, title, prevStart, prevEnd)
        }
    }

    // MARK: - Daily Points Computation

    private func computeDailyPoints(
        periodType: AnalyticsPeriodType,
        startDate: Date,
        endDate: Date,
        meals: [MealRecord],
        targetCalories: Double,
        calendar: Calendar
    ) -> [DailyCaloriePoint] {
        var points: [DailyCaloriePoint] = []
        let dayFormatter = DateFormatter()
        dayFormatter.locale = calendar.locale ?? Locale(identifier: "vi_VN")

        var cursor = startDate
        while cursor <= endDate {
            let dayStart = calendar.startOfDay(for: cursor)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!.addingTimeInterval(-1)

            let daysMeals = meals.filter { $0.timestamp >= dayStart && $0.timestamp <= dayEnd }
            let hasRecords = !daysMeals.isEmpty

            let cal = daysMeals.reduce(0) { $0 + $1.totalCalories }
            let p = daysMeals.reduce(0) { $0 + $1.totalProteinGrams }
            let c = daysMeals.reduce(0) { $0 + $1.totalCarbGrams }
            let f = daysMeals.reduce(0) { $0 + $1.totalFatGrams }
            let fib = daysMeals.reduce(0) { $0 + $1.totalFiberGrams }

            // Labels
            let shortLabel: String
            let fullLabel: String

            switch periodType {
            case .day:
                shortLabel = "Hôm nay"
                dayFormatter.dateFormat = "EEEE, dd/MM"
                fullLabel = dayFormatter.string(from: cursor).capitalized

            case .week:
                let weekday = calendar.component(.weekday, from: cursor)
                shortLabel = Self.vietnameseWeekdayShort(weekday)
                dayFormatter.dateFormat = "EEEE, dd/MM"
                fullLabel = dayFormatter.string(from: cursor).capitalized

            case .month:
                dayFormatter.dateFormat = "d"
                shortLabel = dayFormatter.string(from: cursor)
                dayFormatter.dateFormat = "dd/MM/yyyy"
                fullLabel = dayFormatter.string(from: cursor)
            }

            let idFormatter = DateFormatter()
            idFormatter.dateFormat = "yyyy-MM-dd"
            let pointId = idFormatter.string(from: cursor)

            points.append(
                DailyCaloriePoint(
                    id: pointId,
                    date: cursor,
                    shortLabel: shortLabel,
                    fullDateLabel: fullLabel,
                    calories: cal,
                    targetCalories: targetCalories,
                    hasRecords: hasRecords,
                    proteinGrams: p,
                    carbGrams: c,
                    fatGrams: f,
                    fiberGrams: fib,
                    mealCount: daysMeals.count
                )
            )

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = nextDay
        }

        return points
    }

    private static func vietnameseWeekdayShort(_ weekday: Int) -> String {
        switch weekday {
        case 2: return "T2"
        case 3: return "T3"
        case 4: return "T4"
        case 5: return "T5"
        case 6: return "T6"
        case 7: return "T7"
        case 1: return "CN"
        default: return ""
        }
    }

    // MARK: - Category Breakdown Computation

    private func computeCategoryBreakdown(meals: [MealRecord], totalCalories: Double) -> [CategoryCalorieBreakdown] {
        MealType.allCases.map { cat in
            let inCat = meals.filter { $0.mealType == cat }
            let cal = inCat.reduce(0) { $0 + $1.totalCalories }
            let pct = totalCalories > 0 ? (cal / totalCalories) : 0.0
            return CategoryCalorieBreakdown(category: cat, calories: cal, percentage: pct, mealCount: inCat.count)
        }
    }

    // MARK: - Explainable Insights Generation

    private func generateInsights(
        periodType: AnalyticsPeriodType,
        recordedDays: Int,
        totalDays: Int,
        dailyAverageCalories: Double,
        targetCalories: Double,
        macroDistribution: MacroDistribution,
        dailyAverageFiber: Double,
        categoryBreakdown: [CategoryCalorieBreakdown],
        hasMeals: Bool
    ) -> [NutritionInsight] {
        guard hasMeals else {
            return [
                NutritionInsight(
                    type: .loggingConsistency,
                    title: "Chưa có dữ liệu",
                    message: "Ghi nhận bữa ăn của bạn bằng tính năng Quét AI hoặc Nhật ký để bắt đầu nhận phân tích dinh dưỡng cá nhân hóa.",
                    icon: "chart.bar.doc.horizontal",
                    isPositive: false
                )
            ]
        }

        var insights: [NutritionInsight] = []

        // 1. Goal Progress Insight
        let calRatio = targetCalories > 0 ? (dailyAverageCalories / targetCalories) : 1.0
        if calRatio >= 0.90 && calRatio <= 1.10 {
            insights.append(
                NutritionInsight(
                    type: .goalAchievement,
                    title: "Cân bằng năng lượng tốt",
                    message: "Năng lượng trung bình đạt \(Int(calRatio * 100))% mục tiêu ngày (\(Int(dailyAverageCalories)) / \(Int(targetCalories)) kcal). Bạn đang duy trì mức tiêu thụ rất ổn định.",
                    icon: "flame.fill",
                    isPositive: true
                )
            )
        } else if calRatio < 0.90 {
            insights.append(
                NutritionInsight(
                    type: .goalAchievement,
                    title: "Năng lượng dưới mục tiêu",
                    message: "Mức nạp calo trung bình đạt \(Int(calRatio * 100))% mục tiêu (\(Int(dailyAverageCalories)) kcal). Hãy chú ý bổ sung đủ năng lượng cho các hoạt động thể chất trong ngày.",
                    icon: "arrow.down.forward.circle.fill",
                    isPositive: false
                )
            )
        } else {
            insights.append(
                NutritionInsight(
                    type: .goalAchievement,
                    title: "Vượt mục tiêu năng lượng",
                    message: "Năng lượng trung bình cao hơn mục tiêu \(Int((calRatio - 1.0) * 100))% (\(Int(dailyAverageCalories)) kcal). Bạn có thể cân đối lại khẩu phần các bữa tối hoặc đồ ăn vặt.",
                    icon: "exclamationmark.circle.fill",
                    isPositive: false
                )
            )
        }

        // 2. Logging Consistency Insight (For Week & Month)
        if periodType != .day {
            let pct = Double(recordedDays) / Double(totalDays)
            if pct >= 0.70 {
                insights.append(
                    NutritionInsight(
                        type: .loggingConsistency,
                        title: "Thói quen ghi chép đều đặn",
                        message: "Bạn đã ghi nhận \(recordedDays)/\(totalDays) ngày trong khoảng thời gian này. Việc ghi chép kiên trì giúp biểu đồ dinh dưỡng phản ánh chính xác thực tế.",
                        icon: "calendar.badge.checkmark",
                        isPositive: true
                    )
                )
            } else {
                insights.append(
                    NutritionInsight(
                        type: .loggingConsistency,
                        title: "Cần duy trì đều đặn hơn",
                        message: "Đã có dữ liệu \(recordedDays)/\(totalDays) ngày. Ghi chép đầy đủ các bữa ăn hàng ngày sẽ giúp hệ thống đưa ra khuyến nghị chuẩn xác hơn.",
                        icon: "calendar.badge.clock",
                        isPositive: false
                    )
                )
            }
        }

        // 3. Macronutrient Balance Insight
        let proteinPct = Int(macroDistribution.proteinPercentage * 100)
        let carbPct = Int(macroDistribution.carbPercentage * 100)
        let fatPct = Int(macroDistribution.fatPercentage * 100)
        insights.append(
            NutritionInsight(
                type: .macroBalance,
                title: "Phân bổ năng lượng P:C:F",
                message: "Tỉ lệ calo: Đạm \(proteinPct)%, Tinh bột \(carbPct)%, Chất béo \(fatPct)%. Tỉ lệ khuyến nghị chuẩn là 15-30% Đạm, 45-65% Tinh bột, 20-35% Chất béo.",
                icon: "circle.grid.cross.fill",
                isPositive: proteinPct >= 15 && proteinPct <= 30
            )
        )

        // 4. Fiber Adequacy Insight
        if dailyAverageFiber >= 25 {
            insights.append(
                NutritionInsight(
                    type: .fiberAdequacy,
                    title: "Đủ chất xơ tiêu chuẩn",
                    message: "Lượng chất xơ trung bình đạt \(String(format: "%.1f", dailyAverageFiber))g/ngày, đáp ứng khuyến nghị bảo vệ hệ tiêu hóa của Viện Dinh Dưỡng Quốc Gia.",
                    icon: "leaf.fill",
                    isPositive: true
                )
            )
        } else {
            insights.append(
                NutritionInsight(
                    type: .fiberAdequacy,
                    title: "Bổ sung thêm chất xơ",
                    message: "Lượng chất xơ trung bình đạt \(String(format: "%.1f", dailyAverageFiber))g/ngày (Mục tiêu: 30g). Bạn có thể tăng cường rau luộc, gỏi cuốn hoặc hoa quả tươi trong bữa ăn.",
                    icon: "leaf.circle",
                    isPositive: false
                )
            )
        }

        // 5. Meal Timing / Category Distribution Insight
        if let topCategory = categoryBreakdown.max(by: { $0.calories < $1.calories }), topCategory.calories > 0 {
            let topPct = Int(topCategory.percentage * 100)
            insights.append(
                NutritionInsight(
                    type: .mealDistribution,
                    title: "\(topCategory.category.vietnameseName) chiếm năng lượng cao nhất",
                    message: "\(topCategory.category.vietnameseName) đóng góp \(topPct)% tổng lượng calo nạp vào (\(Int(topCategory.calories)) kcal) qua \(topCategory.mealCount) lần ghi nhận.",
                    icon: "chart.pie.fill",
                    isPositive: true
                )
            )
        }

        return insights
    }
}
