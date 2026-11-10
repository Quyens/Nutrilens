//
//  HomeViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

public struct WeeklyDayNutrition: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let date: Date
    public let dayLabel: String
    public let calories: Double
    public let targetCalories: Double
    public let isToday: Bool

    public var progressRatio: Double {
        guard targetCalories > 0 else { return 0 }
        return min(max(calories / targetCalories, 0), 1.5)
    }
}

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public private(set) var state: AsyncState<NutritionSummary> = .idle
    @Published public private(set) var todaysMeals: [MealRecord] = []
    @Published public private(set) var userProfile: UserProfile = UserProfile()
    @Published public private(set) var weeklyDays: [WeeklyDayNutrition] = []
    @Published public private(set) var weeklyAverageCalories: Double = 0
    @Published public private(set) var weeklyTotalMealsCount: Int = 0
    @Published public private(set) var waterIntakeLiters: Double = 1.8

    private let getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol
    private let mealRepository: MealRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let getDailyHydrationUseCase: GetDailyHydrationUseCaseProtocol
    private let addHydrationUseCase: AddHydrationUseCaseProtocol

    private var todayWaterKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        return "nutrilens_water_intake_" + formatter.string(from: Date())
    }

    public init(
        getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol,
        mealRepository: MealRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        getDailyHydrationUseCase: GetDailyHydrationUseCaseProtocol = GetDailyHydrationUseCase(repository: HydrationRepository()),
        addHydrationUseCase: AddHydrationUseCaseProtocol = AddHydrationUseCase(repository: HydrationRepository())
    ) {
        self.getDailySummaryUseCase = getDailySummaryUseCase
        self.mealRepository = mealRepository
        self.userRepository = userRepository
        self.getDailyHydrationUseCase = getDailyHydrationUseCase
        self.addHydrationUseCase = addHydrationUseCase
    }

    public func loadDashboard() async {
        if case .success = state {
            // Keep existing content rendered during refresh to avoid collapsing scroll view
        } else {
            state = .loading
        }
        await loadWaterIntake()
        do {
            async let summaryTask = getDailySummaryUseCase.execute(for: Date())
            async let mealsTask = mealRepository.fetchMeals(for: Date())
            async let allMealsTask = mealRepository.fetchAllMeals()
            async let profileTask = userRepository.getUserProfile()

            let (summary, meals, allMeals, profile) = try await (summaryTask, mealsTask, allMealsTask, profileTask)
            self.todaysMeals = meals.sorted(by: { $0.timestamp < $1.timestamp })
            self.userProfile = profile
            self.computeWeeklyNutrition(allMeals: allMeals, targetCalories: profile.dailyCalorieTarget)
            self.state = .success(summary)
        } catch let err as AppError {
            self.state = .failure(err)
        } catch {
            self.state = .failure(.unknown(error.localizedDescription))
        }
    }

    public func loadWaterIntake() async {
        do {
            let result = try await getDailyHydrationUseCase.execute(for: Date())
            if result.totalLiters > 0 {
                self.waterIntakeLiters = result.totalLiters
            } else {
                let saved = UserDefaults.standard.double(forKey: todayWaterKey)
                if saved > 0 {
                    self.waterIntakeLiters = saved
                    _ = try? await addHydrationUseCase.execute(amountLiters: saved, timestamp: Date(), notes: "Chuyển tiếp từ phiên trước")
                } else {
                    self.waterIntakeLiters = 1.8
                }
            }
        } catch {
            let saved = UserDefaults.standard.double(forKey: todayWaterKey)
            self.waterIntakeLiters = saved > 0 ? saved : 1.8
        }
    }

    public func addWater(liters: Double) {
        HapticFeedbackService.shared.impact(.light)
        let updated = min(max(self.waterIntakeLiters + liters, 0), 5.0)
        self.waterIntakeLiters = (updated * 10).rounded() / 10
        UserDefaults.standard.set(self.waterIntakeLiters, forKey: todayWaterKey)

        if liters > 0 {
            Task {
                _ = try? await addHydrationUseCase.execute(
                    amountLiters: liters,
                    timestamp: Date(),
                    notes: "Ghi nhận từ Trang chủ"
                )
            }
        }
    }

    public func setWater(liters: Double) {
        let updated = min(max(liters, 0), 5.0)
        self.waterIntakeLiters = (updated * 10).rounded() / 10
        UserDefaults.standard.set(self.waterIntakeLiters, forKey: todayWaterKey)
    }

    public func deleteMeal(id: UUID) async {
        do {
            try await mealRepository.deleteMeal(id: id)
            await loadDashboard()
        } catch {
            AppLogger.data.error("Failed to delete meal: \(error.localizedDescription)")
        }
    }

    private func computeWeeklyNutrition(allMeals: [MealRecord], targetCalories: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var days: [WeeklyDayNutrition] = []
        let weekdaySymbols = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]

        var totalCal: Double = 0
        var daysWithMealsCount = 0
        var totalMealsCount = 0

        for offset in (0..<7).reversed() {
            guard let dayStart = calendar.date(byAdding: .day, value: -offset, to: today),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            let dayMeals = allMeals.filter { $0.timestamp >= dayStart && $0.timestamp < nextDay }
            let dayCal = dayMeals.reduce(0) { $0 + $1.totalCalories }
            if !dayMeals.isEmpty {
                daysWithMealsCount += 1
                totalCal += dayCal
                totalMealsCount += dayMeals.count
            }

            let weekdayIndex = calendar.component(.weekday, from: dayStart) - 1
            let label = (weekdayIndex >= 0 && weekdayIndex < weekdaySymbols.count) ? weekdaySymbols[weekdayIndex] : "T"

            days.append(
                WeeklyDayNutrition(
                    date: dayStart,
                    dayLabel: label,
                    calories: dayCal,
                    targetCalories: targetCalories,
                    isToday: offset == 0
                )
            )
        }

        self.weeklyDays = days
        self.weeklyAverageCalories = daysWithMealsCount > 0 ? (totalCal / Double(daysWithMealsCount)) : 0
        self.weeklyTotalMealsCount = totalMealsCount
    }
}
