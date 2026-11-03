//
//  NutritionAnalyticsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Nutrition Analytics & Insights V2: Calorie trends, macronutrient analysis,
//  P:C:F energy ratios, meal breakdowns, and explainable AI insights.
//

import SwiftUI
import Charts

public struct NutritionAnalyticsView: View {
    @ObservedObject public var viewModel: NutritionAnalyticsViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(viewModel: NutritionAnalyticsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Botanical Background
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // 1. Header & Navigation
                    HeaderSection(viewModel: viewModel)

                    // 2. Main Content based on ViewModel State
                    switch viewModel.state {
                    case .idle, .loading:
                        AnalyticsLoadingSkeleton()
                            .padding(.top, AppSpacing.sm)

                    case .failure(let error):
                        ErrorStateView(
                            title: "Không thể tải số liệu",
                            message: error.localizedDescription
                        ) {
                            Task { await viewModel.loadAnalytics() }
                        }
                        .padding(.top, AppSpacing.xl)

                    case .success(let data):
                        if data.totalCalories == 0 && data.recordedDaysCount == 0 {
                            AnalyticsEmptyView(
                                periodTitle: data.formattedPeriodTitle,
                                onLogFirstMeal: {
                                    // Trigger refresh
                                    Task { await viewModel.loadAnalytics() }
                                }
                            )
                        } else {
                            // 2A. Calorie Hero Card
                            CalorieHeroCard(data: data)

                            // 2B. Interactive Calorie Trends Chart
                            CalorieTrendChartCard(
                                data: data,
                                selectedPoint: viewModel.selectedChartPoint,
                                onSelectPoint: { point in
                                    viewModel.selectPoint(point)
                                }
                            )

                            // 2C. Macronutrient Analysis (4 Pillars)
                            MacronutrientAnalysisCard(data: data)

                            // 2D. Energy Distribution (P:C:F Ratio)
                            EnergyDistributionCard(macroDistribution: data.macroDistribution)

                            // 2E. Meal Category Distribution (for Week / Month)
                            if data.periodType != .day && !data.categoryBreakdown.isEmpty {
                                MealCategoryDistributionCard(breakdowns: data.categoryBreakdown)
                            }

                            // 2F. Explainable Nutrition Insights
                            if !data.insights.isEmpty {
                                InsightsSection(insights: data.insights)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 54) // Dynamic Island / Status Bar safe headroom
                .padding(.bottom, 140) // 140pt clearance for floating bottom bar
            }
            .refreshable {
                await viewModel.loadAnalytics()
            }
        }
        .task {
            if viewModel.state == .idle {
                await viewModel.loadAnalytics()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
    }
}

// MARK: - Header & Navigation Section

private struct HeaderSection: View {
    @ObservedObject var viewModel: NutritionAnalyticsViewModel

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Top Title & Quick Return to Today
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Thống kê")
                        .font(AppTypography.screenTitle)
                        .foregroundColor(AppColors.textPrimaryDark)
                        .accessibilityAddTraits(.isHeader)

                    Text("Xu hướng & phân tích dinh dưỡng")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondaryMuted)
                }

                Spacer()

                if viewModel.canGoForward {
                    Button(action: {
                        viewModel.resetToCurrentPeriod()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Hiện tại")
                                .font(AppTypography.captionBold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.surfaceSecondary)
                        .foregroundColor(AppColors.primaryGreen)
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel("Trở về thời gian hiện tại")
                }
            }

            // Period Selector Chips (Day, Week, Month)
            HStack(spacing: AppSpacing.xs) {
                ForEach(AnalyticsPeriodType.allCases) { period in
                    let isSelected = viewModel.selectedPeriod == period
                    Button(action: {
                        viewModel.selectPeriod(period)
                    }) {
                        Text(period.title)
                            .font(AppTypography.headline)
                            .foregroundColor(isSelected ? .white : AppColors.textPrimaryDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .fill(isSelected ? AppColors.primaryGreen : AppColors.surfacePrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .stroke(isSelected ? Color.clear : AppColors.borderGreenLight, lineWidth: 1)
                            )
                            .shadow(
                                color: isSelected ? AppColors.primaryGreen.opacity(0.25) : Color.black.opacity(0.02),
                                radius: isSelected ? 4 : 2,
                                y: 1
                            )
                    }
                    .accessibilityLabel("Chọn xem theo \(period.title)")
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                }
            }

            // Period Navigator (< Period Title >)
            HStack {
                Button(action: {
                    viewModel.shiftPeriod(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimaryDark)
                        .frame(width: 34, height: 34)
                        .background(AppColors.surfacePrimary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.borderGreenLight, lineWidth: 1))
                }
                .accessibilityLabel("Kỳ trước")

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.primaryGreen)

                    Text(viewModel.periodSubtitle)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimaryDark)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.surfacePrimary.opacity(0.85))
                .clipShape(Capsule())

                Spacer()

                Button(action: {
                    viewModel.shiftPeriod(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(viewModel.canGoForward ? AppColors.textPrimaryDark : AppColors.textSecondaryMuted.opacity(0.4))
                        .frame(width: 34, height: 34)
                        .background(AppColors.surfacePrimary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.borderGreenLight, lineWidth: 1))
                }
                .disabled(!viewModel.canGoForward)
                .accessibilityLabel("Kỳ sau")
            }
            .padding(.top, 2)
        }
    }
}

// MARK: - Calorie Hero Card

private struct CalorieHeroCard: View {
    let data: PeriodAnalyticsData

    private var percentOfTarget: Int {
        guard data.targetCalories > 0 else { return 0 }
        let current = (data.periodType == .day) ? data.totalCalories : data.dailyAverageCalories
        return Int((current / data.targetCalories) * 100)
    }

    private var adherenceStatus: (text: String, color: Color, icon: String) {
        if percentOfTarget == 0 {
            return ("Chưa ghi nhận", AppColors.textSecondaryMuted, "questionmark.circle")
        } else if percentOfTarget < 80 {
            return ("Dưới mục tiêu", AppColors.peachOrange, "arrow.down.forward")
        } else if percentOfTarget <= 110 {
            return ("Đạt mục tiêu", AppColors.primaryGreen, "checkmark.circle.fill")
        } else {
            return ("Vượt mục tiêu", AppColors.fatCoral, "exclamationmark.circle")
        }
    }

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Top row: Section title & Adherence pill
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(data.periodType == .day ? "Calo Hôm Nay" : "Trung Bình Ngày")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textSecondaryMuted)
                            .textCase(.uppercase)

                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            let value = (data.periodType == .day) ? data.totalCalories : data.dailyAverageCalories
                            Text("\(Int(value.rounded()))")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimaryDark)

                            Text("/ \(Int(data.targetCalories)) kcal")
                                .font(AppTypography.subheadlineBold)
                                .foregroundColor(AppColors.textSecondaryMuted)
                        }
                    }

                    Spacer()

                    // Adherence badge
                    HStack(spacing: 4) {
                        Image(systemName: adherenceStatus.icon)
                            .font(.system(size: 11, weight: .bold))
                        Text(adherenceStatus.text)
                            .font(AppTypography.captionBold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(adherenceStatus.color.opacity(0.12))
                    .foregroundColor(adherenceStatus.color)
                    .clipShape(Capsule())
                }

                // Progress Bar
                GeometryReader { geometry in
                    let clampedRatio = min(1.0, max(0.0, Double(percentOfTarget) / 100.0))
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.mintSurface)
                            .frame(height: 10)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.softGreen, AppColors.primaryGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * clampedRatio, height: 10)
                    }
                }
                .frame(height: 10)

                // Bottom meta indicators
                HStack {
                    // Target achievement percentage
                    HStack(spacing: 4) {
                        Text("\(percentOfTarget)%")
                            .font(AppTypography.subheadlineBold)
                            .foregroundColor(AppColors.primaryGreen)
                        Text("mục tiêu calo")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                    }

                    Spacer()

                    // Comparative indicator vs previous period
                    if let change = data.calorieChangePercentage {
                        HStack(spacing: 3) {
                            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 10, weight: .bold))
                            Text(String(format: "%@%.1f%% vs kỳ trước", change >= 0 ? "+" : "", change))
                                .font(AppTypography.captionBold)
                        }
                        .foregroundColor(abs(change) <= 10 ? AppColors.primaryGreen : AppColors.carbsOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(Capsule())
                    } else if data.periodType != .day {
                        // Show recorded days count
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 10))
                            Text("Ghi nhận \(data.recordedDaysCount)/\(data.totalDaysInPeriod) ngày")
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(AppColors.textSecondaryMuted)
                    }
                }
            }
        }
    }
}

// MARK: - Interactive Calorie Trend Chart Card

private struct CalorieTrendChartCard: View {
    let data: PeriodAnalyticsData
    let selectedPoint: DailyCaloriePoint?
    let onSelectPoint: (DailyCaloriePoint?) -> Void

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Xu Hướng Năng Lượng")
                            .font(AppTypography.cardTitle)
                            .foregroundColor(AppColors.textPrimaryDark)

                        Text(data.periodType == .day ? "Phân bổ calo theo bữa ăn hôm nay" : "Nhấn vào cột để xem chi tiết từng ngày")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                    }

                    Spacer()

                    // Target legend item
                    HStack(spacing: 4) {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                            .foregroundColor(AppColors.textSecondaryMuted)
                            .frame(width: 16, height: 1.5)

                        Text("Mục tiêu")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                    }
                }

                if data.periodType == .day {
                    // Day view: Show meals of the day
                    DayMealsChart(breakdowns: data.categoryBreakdown, targetCalories: data.targetCalories)
                } else {
                    // Week or Month time series chart
                    TimeSeriesCalorieChart(
                        points: data.dailyPoints,
                        targetCalories: data.targetCalories,
                        selectedPoint: selectedPoint,
                        onSelectPoint: onSelectPoint
                    )
                }

                // Interactive Selected Point Inspector Card
                if let selected = selectedPoint {
                    SelectedPointDetailView(point: selected) {
                        onSelectPoint(nil)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Time Series Calorie Chart (Apple Swift Charts)

private struct TimeSeriesCalorieChart: View {
    let points: [DailyCaloriePoint]
    let targetCalories: Double
    let selectedPoint: DailyCaloriePoint?
    let onSelectPoint: (DailyCaloriePoint?) -> Void

    private var maxCalories: Double {
        let highest = points.map(\.calories).max() ?? 0
        return max(targetCalories * 1.25, highest * 1.15, 500)
    }

    var body: some View {
        VStack(spacing: 8) {
            Chart {
                // 1. Target line
                RuleMark(y: .value("Mục tiêu", targetCalories))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .foregroundStyle(AppColors.textSecondaryMuted.opacity(0.6))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("\(Int(targetCalories))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppColors.textSecondaryMuted)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(AppColors.surfacePrimary.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }

                // 2. Daily Intake Bars
                ForEach(points) { point in
                    let isSelected = selectedPoint?.id == point.id

                    if point.hasRecords {
                        // Recorded Day with actual intake
                        BarMark(
                            x: .value("Ngày", point.shortLabel),
                            y: .value("Calo", point.calories)
                        )
                        .foregroundStyle(
                            isSelected
                                ? AppColors.primaryGreen
                                : (point.calories > targetCalories * 1.15
                                    ? AppColors.carbsOrange.opacity(0.85)
                                    : AppColors.primaryGreen.opacity(0.75))
                        )
                        .cornerRadius(5, style: .continuous)
                    } else {
                        // Distinguish unrecorded days: Show ghost bar up to a tiny baseline
                        BarMark(
                            x: .value("Ngày", point.shortLabel),
                            y: .value("Calo", 60.0) // Ghost height
                        )
                        .foregroundStyle(AppColors.borderGreenLight.opacity(0.7))
                        .cornerRadius(3, style: .continuous)
                    }
                }
            }
            .chartYScale(domain: 0...maxCalories)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3]))
                        .foregroundStyle(AppColors.borderGreenLight)
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text("\(intVal)")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(AppColors.textSecondaryMuted)
                        }
                    }
                }
            }
            .chartXAxis {
                if points.count > 7 {
                    // Month view: show clean spaced labels (1, 5, 10, 15, 20, 25, 30)
                    AxisMarks(values: points.filter { p in
                        guard let dayNum = Int(p.shortLabel) else { return false }
                        return dayNum == 1 || dayNum % 5 == 0
                    }.map(\.shortLabel)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(AppColors.borderGreenLight)
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textSecondaryMuted)
                            }
                        }
                    }
                } else {
                    // Week view: show all 7 days
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textPrimaryDark)
                            }
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // Find matching short label
                            if let xLabel: String = proxy.value(atX: location.x) {
                                if let matched = points.first(where: { $0.shortLabel == xLabel }) {
                                    if selectedPoint?.id == matched.id {
                                        onSelectPoint(nil)
                                    } else {
                                        onSelectPoint(matched)
                                    }
                                }
                            }
                        }
                }
            }

            // Unrecorded day legend disclaimer
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColors.primaryGreen)
                        .frame(width: 8, height: 8)
                    Text("Đã ghi nhận")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondaryMuted)
                }

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.borderGreenLight)
                        .frame(width: 8, height: 8)
                    Text("Chưa ghi chép")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondaryMuted)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Day Meals Breakdown Chart

private struct DayMealsChart: View {
    let breakdowns: [CategoryCalorieBreakdown]
    let targetCalories: Double

    private var activeBreakdowns: [CategoryCalorieBreakdown] {
        breakdowns.filter { $0.calories > 0 }
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if activeBreakdowns.isEmpty {
                Text("Chưa có bữa ăn nào được ghi nhận cho hôm nay.")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondaryMuted)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            } else {
                Chart {
                    ForEach(activeBreakdowns) { item in
                        BarMark(
                            x: .value("Bữa", item.category.vietnameseName),
                            y: .value("Calo", item.calories)
                        )
                        .foregroundStyle(categoryColor(for: item.category))
                        .cornerRadius(6, style: .continuous)
                        .annotation(position: .top) {
                            Text("\(Int(item.calories))")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.textPrimaryDark)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(AppColors.borderGreenLight)
                        AxisValueLabel()
                    }
                }
                .frame(height: 180)
            }
        }
    }

    private func categoryColor(for type: MealType) -> Color {
        switch type {
        case .breakfast: return AppColors.peachOrange
        case .lunch: return AppColors.primaryGreen
        case .dinner: return AppColors.proteinBlue
        case .snack: return AppColors.fatCoral
        }
    }
}

// MARK: - Selected Point Popover Detail View

private struct SelectedPointDetailView: View {
    let point: DailyCaloriePoint
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(AppColors.primaryGreen)
                    Text(point.fullDateLabel)
                        .font(AppTypography.cardTitle)
                        .foregroundColor(AppColors.textPrimaryDark)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondaryMuted)
                        .font(.system(size: 16))
                }
            }

            if point.hasRecords {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tổng calo")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                        Text("\(Int(point.calories)) kcal")
                            .font(AppTypography.headlineBold)
                            .foregroundColor(AppColors.textPrimaryDark)
                    }

                    Divider().frame(height: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bữa ăn")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                        Text("\(point.mealCount) bữa")
                            .font(AppTypography.headlineBold)
                            .foregroundColor(AppColors.primaryGreen)
                    }

                    Divider().frame(height: 28)

                    // Macro pills
                    HStack(spacing: 6) {
                        MacroMiniPill(label: "Đạm", grams: point.proteinGrams, color: AppColors.proteinBlue)
                        MacroMiniPill(label: "Carb", grams: point.carbGrams, color: AppColors.carbsOrange)
                        MacroMiniPill(label: "Béo", grams: point.fatGrams, color: AppColors.fatCoral)
                    }
                }
            } else {
                Text("Chưa ghi chép nhật ký cho ngày này.")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondaryMuted)
                    .padding(.vertical, 4)
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surfaceSecondary.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}

private struct MacroMiniPill: View {
    let label: String
    let grams: Double
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(color)
            Text("\(Int(grams))g")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textPrimaryDark)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Macronutrient Analysis Card (4 Pillars)

private struct MacronutrientAnalysisCard: View {
    let data: PeriodAnalyticsData

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phân Tích Dinh Dưỡng")
                            .font(AppTypography.cardTitle)
                            .foregroundColor(AppColors.textPrimaryDark)

                        Text(data.periodType == .day ? "Lượng tiêu thụ so với mục tiêu ngày" : "Trung bình tiêu thụ mỗi ngày đã ghi")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                    }

                    Spacer()
                }

                // 2x2 Grid of Macro Metric Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                    MacroMetricTile(
                        title: "Chất đạm (Protein)",
                        currentGrams: data.periodType == .day ? data.totalProtein : data.dailyAverageProtein,
                        targetGrams: data.targetProtein,
                        accentColor: AppColors.proteinBlue,
                        icon: "fork.knife"
                    )

                    MacroMetricTile(
                        title: "Tinh bột (Carbs)",
                        currentGrams: data.periodType == .day ? data.totalCarbs : data.dailyAverageCarbs,
                        targetGrams: data.targetCarbs,
                        accentColor: AppColors.carbsOrange,
                        icon: "leaf.fill"
                    )

                    MacroMetricTile(
                        title: "Chất béo (Fat)",
                        currentGrams: data.periodType == .day ? data.totalFat : data.dailyAverageFat,
                        targetGrams: data.targetFat,
                        accentColor: AppColors.fatCoral,
                        icon: "drop.fill"
                    )

                    MacroMetricTile(
                        title: "Chất xơ (Fiber)",
                        currentGrams: data.periodType == .day ? data.totalFiber : data.dailyAverageFiber,
                        targetGrams: data.targetFiber,
                        accentColor: AppColors.softGreen,
                        icon: "sparkles"
                    )
                }
            }
        }
    }
}

private struct MacroMetricTile: View {
    let title: String
    let currentGrams: Double
    let targetGrams: Double
    let accentColor: Color
    let icon: String

    private var percentage: Int {
        guard targetGrams > 0 else { return 0 }
        return Int((currentGrams / targetGrams) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                        .foregroundColor(accentColor)
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondaryMuted)
                        .lineLimit(1)
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(currentGrams.rounded()))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimaryDark)

                Text("/ \(Int(targetGrams))g")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondaryMuted)

                Spacer()

                Text("\(percentage)%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(percentage >= 80 && percentage <= 120 ? AppColors.primaryGreen : AppColors.carbsOrange)
            }

            // Progress Line
            GeometryReader { geo in
                let ratio = min(1.0, max(0.0, Double(percentage) / 100.0))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(accentColor.opacity(0.15))
                        .frame(height: 6)
                    Capsule()
                        .fill(accentColor)
                        .frame(width: geo.size.width * ratio, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(AppColors.borderGreenLight, lineWidth: 1)
        )
    }
}

// MARK: - Energy Distribution Card (P:C:F Ratio)

private struct EnergyDistributionCard: View {
    let macroDistribution: MacroDistribution

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tỉ Lệ Năng Lượng (P : C : F)")
                            .font(AppTypography.cardTitle)
                            .foregroundColor(AppColors.textPrimaryDark)

                        Text("Tỉ lệ calo phân bổ từ Protein, Carbs, và Fat")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondaryMuted)
                    }

                    Spacer()
                }

                if macroDistribution.totalEnergyCalories > 0 {
                    // Segmented Stacked Ratio Bar
                    GeometryReader { geo in
                        let pWidth = geo.size.width * macroDistribution.proteinPercentage
                        let cWidth = geo.size.width * macroDistribution.carbPercentage
                        let fWidth = max(0, geo.size.width - pWidth - cWidth)

                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppColors.proteinBlue)
                                .frame(width: max(2, pWidth))

                            Rectangle()
                                .fill(AppColors.carbsOrange)
                                .frame(width: max(2, cWidth))

                            Rectangle()
                                .fill(AppColors.fatCoral)
                                .frame(width: max(2, fWidth))
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 14)

                    // Legend & percentages
                    HStack(spacing: AppSpacing.sm) {
                        RatioLegendItem(
                            label: "Đạm",
                            percent: Int(macroDistribution.proteinPercentage * 100),
                            recommended: "20-30%",
                            color: AppColors.proteinBlue
                        )

                        Spacer()

                        RatioLegendItem(
                            label: "Carb",
                            percent: Int(macroDistribution.carbPercentage * 100),
                            recommended: "45-65%",
                            color: AppColors.carbsOrange
                        )

                        Spacer()

                        RatioLegendItem(
                            label: "Béo",
                            percent: Int(macroDistribution.fatPercentage * 100),
                            recommended: "20-35%",
                            color: AppColors.fatCoral
                        )
                    }
                    .padding(.top, 4)
                } else {
                    Text("Chưa có đủ dữ liệu dinh dưỡng để tính tỉ lệ năng lượng.")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondaryMuted)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

private struct RatioLegendItem: View {
    let label: String
    let percent: Int
    let recommended: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(label)
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textPrimaryDark)
                    Text("\(percent)%")
                        .font(AppTypography.captionBold)
                        .foregroundColor(color)
                }
                Text("Chuẩn: \(recommended)")
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textSecondaryMuted)
            }
        }
    }
}

// MARK: - Meal Category Distribution Card

private struct MealCategoryDistributionCard: View {
    let breakdowns: [CategoryCalorieBreakdown]

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Phân Bổ Theo Bữa Ăn")
                    .font(AppTypography.cardTitle)
                    .foregroundColor(AppColors.textPrimaryDark)

                VStack(spacing: AppSpacing.sm) {
                    ForEach(breakdowns) { item in
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: item.category.systemIcon)
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.primaryGreen)
                                .frame(width: 24)

                            Text(item.category.vietnameseName)
                                .font(AppTypography.subheadlineBold)
                                .foregroundColor(AppColors.textPrimaryDark)
                                .frame(width: 75, alignment: .leading)

                            // Horizontal Bar
                            GeometryReader { geo in
                                let clamped = min(1.0, max(0.0, item.percentage))
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(AppColors.mintSurface)
                                        .frame(height: 8)
                                    Capsule()
                                        .fill(AppColors.primaryGreen)
                                        .frame(width: geo.size.width * clamped, height: 8)
                                }
                            }
                            .frame(height: 8)

                            Text("\(Int(item.percentage * 100))%")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.primaryGreen)
                                .frame(width: 38, alignment: .trailing)

                            Text("\(Int(item.calories)) kcal")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondaryMuted)
                                .frame(width: 65, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private func iconForCategory(_ category: MealType) -> String {
        switch category {
        case .breakfast: return "sun.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "cup.and.saucer"
        }
    }
}

// MARK: - Explainable Nutrition Insights Section

private struct InsightsSection: View {
    let insights: [NutritionInsight]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.primaryGreen)
                Text("Nhận Định Từ Dữ Liệu")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimaryDark)
            }

            VStack(spacing: AppSpacing.sm) {
                ForEach(insights) { insight in
                    InsightRowCard(insight: insight)
                }
            }
        }
    }
}

private struct InsightRowCard: View {
    let insight: NutritionInsight

    var body: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                // Icon Badge
                ZStack {
                    Circle()
                        .fill(insight.isPositive ? AppColors.mintSurface : AppColors.peachOrange.opacity(0.2))
                        .frame(width: 38, height: 38)

                    Image(systemName: insight.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(insight.isPositive ? AppColors.primaryGreen : AppColors.carbsOrange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(insight.title)
                        .font(AppTypography.cardTitle)
                        .foregroundColor(AppColors.textPrimaryDark)

                    Text(insight.message)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondaryMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Empty State View

private struct AnalyticsEmptyView: View {
    let periodTitle: String
    let onLogFirstMeal: () -> Void

    var body: some View {
        CardView(padding: AppSpacing.xl, cornerRadius: AppRadius.card) {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.softGreen)

                Text("Chưa có dữ liệu bữa ăn")
                    .font(AppTypography.cardTitle)
                    .foregroundColor(AppColors.textPrimaryDark)

                Text("Trong khoảng thời gian \(periodTitle), bạn chưa ghi nhận bữa ăn nào. Hãy quét món ăn để xem thống kê calo và vi chất dinh dưỡng nhé!")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondaryMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.sm)

                Button(action: onLogFirstMeal) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Làm mới")
                    }
                    .font(AppTypography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryGreen)
                    .clipShape(Capsule())
                }
                .padding(.top, AppSpacing.xs)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

// MARK: - Loading Skeleton

private struct AnalyticsLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Hero card skeleton
            CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.borderGreenLight.opacity(0.7))
                        .frame(width: 140, height: 16)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.borderGreenLight.opacity(0.7))
                        .frame(width: 220, height: 32)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.borderGreenLight.opacity(0.7))
                        .frame(height: 10)
                }
            }

            // Chart skeleton
            CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.borderGreenLight.opacity(0.7))
                        .frame(width: 180, height: 18)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.borderGreenLight.opacity(0.5))
                        .frame(height: 180)
                }
            }
        }
    }
}
