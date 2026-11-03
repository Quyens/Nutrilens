//
//  NutritionAnalyticsTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Unit tests for Nutrition Analytics V2: Period boundary calculation,
//  unrecorded vs zero-calorie distinction, time-series aggregation,
//  macro energy ratios (4-4-9 rule), prior-period comparisons, and explainable insights.
//

import XCTest
@testable import NutriLens

@MainActor
final class NutritionAnalyticsTests: XCTestCase {

    private func makeSampleMeal(
        id: UUID = UUID(),
        name: String,
        category: MealType,
        timestamp: Date,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0
    ) -> MealRecord {
        let item = FoodItem(
            name: name,
            vietnameseName: name,
            confidence: 0.95,
            servingSizeGrams: 300,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat,
            fiberGrams: fiber
        )
        return MealRecord(
            id: id,
            timestamp: timestamp,
            mealType: category,
            items: [item]
        )
    }

    // MARK: - 1. Daily Analytics Test
    func testDayPeriodAnalytics() async throws {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)

        let meal1 = makeSampleMeal(
            name: "Phở Bò Tái",
            category: .breakfast,
            timestamp: calendar.date(byAdding: .hour, value: 8, to: startOfDay)!,
            calories: 550,
            protein: 30,
            carbs: 65,
            fat: 15,
            fiber: 4
        )

        let meal2 = makeSampleMeal(
            name: "Cơm Tấm Sườn Bì Chả",
            category: .lunch,
            timestamp: calendar.date(byAdding: .hour, value: 12, to: startOfDay)!,
            calories: 750,
            protein: 35,
            carbs: 85,
            fat: 25,
            fiber: 3
        )

        let mealRepo = MockMealRepository(initialMeals: [meal1, meal2])
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let result = try await useCase.execute(periodType: .day, anchorDate: today, calendar: calendar)

        XCTAssertEqual(result.periodType, .day)
        XCTAssertEqual(result.totalCalories, 1300, accuracy: 0.1)
        XCTAssertEqual(result.totalProtein, 65, accuracy: 0.1)
        XCTAssertEqual(result.totalCarbs, 150, accuracy: 0.1)
        XCTAssertEqual(result.totalFat, 40, accuracy: 0.1)
        XCTAssertEqual(result.totalFiber, 7, accuracy: 0.1)
        XCTAssertEqual(result.categoryBreakdown.count, 4, "Breakdown includes all 4 MealType categories")
        let activeCategories = result.categoryBreakdown.filter { $0.mealCount > 0 }
        XCTAssertEqual(activeCategories.count, 2, "2 active categories logged (breakfast & lunch)")
    }

    // MARK: - 2. Weekly Aggregation & Boundary Test
    func testWeeklyPeriodAggregation() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Create meals on 3 separate days this week
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 12
        let monday = calendar.date(from: dateComponents)!
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!
        let friday = calendar.date(byAdding: .day, value: 4, to: monday)!

        let m1 = makeSampleMeal(name: "Phở", category: .breakfast, timestamp: monday, calories: 500, protein: 25, carbs: 60, fat: 12)
        let m2 = makeSampleMeal(name: "Cơm Tấm", category: .lunch, timestamp: wednesday, calories: 700, protein: 35, carbs: 80, fat: 20)
        let m3 = makeSampleMeal(name: "Bún Bò", category: .dinner, timestamp: friday, calories: 600, protein: 30, carbs: 70, fat: 18)

        let mealRepo = MockMealRepository(initialMeals: [m1, m2, m3])
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let result = try await useCase.execute(periodType: .week, anchorDate: monday, calendar: calendar)

        XCTAssertEqual(result.periodType, .week)
        XCTAssertEqual(result.dailyPoints.count, 7, "Weekly analytics must have 7 daily points")
        XCTAssertEqual(result.recordedDaysCount, 3, "Only days with logged meals should count as recorded")
        XCTAssertEqual(result.totalCalories, 1800, accuracy: 0.1)

        // Average should be based on recorded days (1800 / 3 = 600), not diluted by unrecorded days
        XCTAssertEqual(result.dailyAverageCalories, 600, accuracy: 0.1)
    }

    // MARK: - 3. Unrecorded vs Zero-Calorie Distinction
    func testUnrecordedVsZeroCaloriesDistinction() async throws {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)

        // Create a 0-calorie recorded meal (e.g. green tea)
        let zeroMeal = makeSampleMeal(
            name: "Trà Xanh Không Đường",
            category: .snack,
            timestamp: startOfDay,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0
        )

        let mealRepo = MockMealRepository(initialMeals: [zeroMeal])
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let result = try await useCase.execute(periodType: .week, anchorDate: today, calendar: calendar)

        let recordedDays = result.dailyPoints.filter { $0.hasRecords }
        let unrecordedDays = result.dailyPoints.filter { !$0.hasRecords }

        XCTAssertEqual(recordedDays.count, 1, "The zero-calorie logged meal must be recognized as a recorded day")
        XCTAssertEqual(recordedDays.first?.calories, 0)
        XCTAssertTrue(recordedDays.first!.hasRecords)

        XCTAssertEqual(unrecordedDays.count, 6, "Days without entries must be flagged as unrecorded")
        XCTAssertEqual(unrecordedDays.first?.calories, 0)
        XCTAssertFalse(unrecordedDays.first!.hasRecords)
    }

    // MARK: - 4. Macronutrient Energy Distribution (4-4-9 Rule)
    func testMacronutrientEnergyDistribution() {
        // 25g protein = 100 kcal
        // 50g carbs = 200 kcal
        // 20g fat = 180 kcal
        // Total energy = 480 kcal
        let macro = MacroDistribution(
            proteinGrams: 25,
            carbGrams: 50,
            fatGrams: 20,
            fiberGrams: 5
        )

        XCTAssertEqual(macro.proteinCalories, 100, accuracy: 0.01)
        XCTAssertEqual(macro.carbCalories, 200, accuracy: 0.01)
        XCTAssertEqual(macro.fatCalories, 180, accuracy: 0.01)
        XCTAssertEqual(macro.totalEnergyCalories, 480, accuracy: 0.01)

        XCTAssertEqual(macro.proteinPercentage, 100.0 / 480.0, accuracy: 0.001)
        XCTAssertEqual(macro.carbPercentage, 200.0 / 480.0, accuracy: 0.001)
        XCTAssertEqual(macro.fatPercentage, 180.0 / 480.0, accuracy: 0.001)

        let sumPercentage = macro.proteinPercentage + macro.carbPercentage + macro.fatPercentage
        XCTAssertEqual(sumPercentage, 1.0, accuracy: 0.001, "Energy percentages must sum to 100%")
    }

    // MARK: - 5. Prior Period Comparative Calculation
    func testPriorPeriodComparison() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Current week date (Wednesday)
        let currentWednesday = calendar.date(byAdding: .day, value: 0, to: today)!
        // Previous week date (-7 days)
        let prevWednesday = calendar.date(byAdding: .day, value: -7, to: today)!

        let currentMeal = makeSampleMeal(name: "Phở", category: .lunch, timestamp: currentWednesday, calories: 1000, protein: 40, carbs: 100, fat: 20)
        let prevMeal = makeSampleMeal(name: "Phở", category: .lunch, timestamp: prevWednesday, calories: 800, protein: 30, carbs: 80, fat: 15)

        let mealRepo = MockMealRepository(initialMeals: [currentMeal, prevMeal])
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let result = try await useCase.execute(periodType: .week, anchorDate: currentWednesday, calendar: calendar)

        XCTAssertNotNil(result.previousPeriodCalories)
        XCTAssertEqual(result.previousPeriodCalories!, 800, accuracy: 0.1)

        // Change percentage: (1000 - 800) / 800 * 100 = +25%
        XCTAssertNotNil(result.calorieChangePercentage)
        XCTAssertEqual(result.calorieChangePercentage!, 25.0, accuracy: 0.1)
    }

    // MARK: - 6. Explainable Insight Generation
    func testDeterministicInsightsGeneration() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Log 5 days of healthy meals within target range
        var meals: [MealRecord] = []
        for i in 0..<5 {
            let day = calendar.date(byAdding: .day, value: -i, to: today)!
            meals.append(
                makeSampleMeal(
                    name: "Healthy Meal \(i)",
                    category: .lunch,
                    timestamp: day,
                    calories: 2000,
                    protein: 110,
                    carbs: 220,
                    fat: 55,
                    fiber: 28
                )
            )
        }

        let mealRepo = MockMealRepository(initialMeals: meals)
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let result = try await useCase.execute(periodType: .week, anchorDate: today, calendar: calendar)

        XCTAssertFalse(result.insights.isEmpty, "Analytics should generate explainable insights")

        let titles = result.insights.map(\.title)
        // Should contain goal adherence insight and logging consistency
        XCTAssertTrue(titles.contains { $0.contains("mục tiêu") || $0.contains("thói quen") || $0.contains("chất xơ") || $0.contains("đạm") })
    }

    // MARK: - 7. ViewModel Period Navigation & Disallowing Future
    func testViewModelPeriodNavigation() async throws {
        let mealRepo = MockMealRepository(initialMeals: [])
        let userRepo = MockUserRepository()
        let useCase = GetNutritionAnalyticsUseCase(mealRepository: mealRepo, userRepository: userRepo)

        let vm = NutritionAnalyticsViewModel(getNutritionAnalyticsUseCase: useCase)

        // Default period is .week
        XCTAssertEqual(vm.selectedPeriod, .week)
        XCTAssertFalse(vm.canGoForward, "Cannot navigate forward past current week")

        // Shift backward by 1 week
        vm.shiftPeriod(by: -1)
        XCTAssertTrue(vm.canGoForward, "Can navigate forward when looking at past week")

        // Shift forward returns to current week
        vm.shiftPeriod(by: 1)
        XCTAssertFalse(vm.canGoForward, "Back to current week, cannot go forward")

        // Switch to Month
        vm.selectPeriod(.month)
        XCTAssertEqual(vm.selectedPeriod, .month)
        XCTAssertFalse(vm.canGoForward, "Cannot navigate forward past current month")

        // Switch to Day
        vm.selectPeriod(.day)
        XCTAssertEqual(vm.selectedPeriod, .day)
        XCTAssertFalse(vm.canGoForward, "Cannot navigate forward past today")
    }
}
