//
//  MealDiaryTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Verifies Meal Diary V2 features: Weekly strip dates, grouped category filtering,
//  real-time daily aggregates, search, full CRUD (create, read, update, delete), and persistence.
//

import XCTest
@testable import NutriLens

@MainActor
final class MealDiaryTests: XCTestCase {

    private func makeSampleMeal(
        id: UUID = UUID(),
        name: String,
        category: MealType,
        timestamp: Date = Date(),
        grams: Double = 350,
        calories: Double = 450,
        protein: Double = 25,
        carbs: Double = 55,
        fat: Double = 12,
        fiber: Double = 3,
        notes: String? = nil
    ) -> MealRecord {
        let item = FoodItem(
            name: name,
            vietnameseName: name,
            confidence: 0.98,
            servingSizeGrams: grams,
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
            items: [item],
            notes: notes,
            imagePath: "pho"
        )
    }

    func testWeeklyCalendarDatesCalculation() {
        let repo = MockMealRepository(initialMeals: [])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        let weekDates = vm.currentWeekDates
        XCTAssertEqual(weekDates.count, 7, "Weekly calendar must always produce exactly 7 days (Monday to Sunday)")

        let calendar = Calendar.current
        // Verify Monday is first day (weekday 2 in Gregorian)
        let firstWeekday = calendar.component(.weekday, from: weekDates[0])
        XCTAssertEqual(firstWeekday, 2, "First day of week must be Monday")

        // Verify Sunday is last day (weekday 1 in Gregorian)
        let lastWeekday = calendar.component(.weekday, from: weekDates[6])
        XCTAssertEqual(lastWeekday, 1, "Last day of week must be Sunday")
    }

    func testCategorizedMealsAndCalories() async {
        let now = Date()
        let breakfast = makeSampleMeal(name: "Phở Bò", category: MealType.breakfast, timestamp: now, calories: 450)
        let lunch = makeSampleMeal(name: "Cơm Tấm", category: MealType.lunch, timestamp: now, calories: 650)
        let dinner = makeSampleMeal(name: "Bún Bò Huế", category: MealType.dinner, timestamp: now, calories: 580)
        let snack = makeSampleMeal(name: "Chè Đậu Đỏ", category: MealType.snack, timestamp: now, calories: 220)

        let repo = MockMealRepository(initialMeals: [breakfast, lunch, dinner, snack])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()

        // Check categorized meals
        XCTAssertEqual(vm.meals(for: MealType.breakfast).count, 1)
        XCTAssertEqual(vm.meals(for: MealType.lunch).count, 1)
        XCTAssertEqual(vm.meals(for: MealType.dinner).count, 1)
        XCTAssertEqual(vm.meals(for: MealType.snack).count, 1)

        // Check category calories
        XCTAssertEqual(vm.categoryCalories(for: MealType.breakfast), 450)
        XCTAssertEqual(vm.categoryCalories(for: MealType.lunch), 650)
        XCTAssertEqual(vm.categoryCalories(for: MealType.dinner), 580)
        XCTAssertEqual(vm.categoryCalories(for: MealType.snack), 220)
    }

    func testDailyMacroAggregates() async {
        let now = Date()
        let meal1 = makeSampleMeal(
            name: "Món 1", category: MealType.lunch, timestamp: now,
            calories: 500, protein: 30, carbs: 60, fat: 15, fiber: 4
        )
        let meal2 = makeSampleMeal(
            name: "Món 2", category: MealType.dinner, timestamp: now,
            calories: 700, protein: 40, carbs: 80, fat: 20, fiber: 6
        )

        let repo = MockMealRepository(initialMeals: [meal1, meal2])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()

        XCTAssertEqual(vm.totalCalories, 1200)
        XCTAssertEqual(vm.totalProtein, 70)
        XCTAssertEqual(vm.totalCarbs, 140)
        XCTAssertEqual(vm.totalFat, 35)
        XCTAssertEqual(vm.totalFiber, 10)
        XCTAssertEqual(vm.remainingCalories, 800) // 2000 target - 1200
        XCTAssertEqual(vm.calorieProgress, 0.6)
    }

    func testSearchFiltering() async {
        let now = Date()
        let pho = makeSampleMeal(name: "Phở Bò Tái", category: MealType.breakfast, timestamp: now, notes: "Nhiều hành hoa")
        let comTam = makeSampleMeal(name: "Cơm Tấm Sườn Nướng", category: MealType.lunch, timestamp: now, notes: "Thêm trứng ốp la")

        let repo = MockMealRepository(initialMeals: [pho, comTam])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()

        // Match by title
        vm.searchQuery = "phở"
        XCTAssertEqual(vm.filteredDayMeals.count, 1)
        XCTAssertEqual(vm.filteredDayMeals.first?.displayTitle, "Phở Bò Tái")

        // Match by notes
        vm.searchQuery = "ốp la"
        XCTAssertEqual(vm.filteredDayMeals.count, 1)
        XCTAssertEqual(vm.filteredDayMeals.first?.displayTitle, "Cơm Tấm Sườn Nướng")

        // No match
        vm.searchQuery = "bánh mì"
        XCTAssertEqual(vm.filteredDayMeals.count, 0)
    }

    func testMealUpdateAndAggregatesSync() async {
        let now = Date()
        let originalMeal = makeSampleMeal(
            name: "Phở Gà", category: MealType.breakfast, timestamp: now,
            calories: 400, protein: 20, carbs: 50, fat: 10, fiber: 2
        )

        let repo = MockMealRepository(initialMeals: [originalMeal])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()
        XCTAssertEqual(vm.totalCalories, 400)

        // Modify portion size and nutrition
        let updatedItem = FoodItem(
            name: "Phở Gà",
            vietnameseName: "Phở Gà Đặc Biệt",
            confidence: 1.0,
            servingSizeGrams: 550,
            calories: 600,
            proteinGrams: 35,
            carbGrams: 70,
            fatGrams: 15,
            fiberGrams: 3
        )
        let updatedMeal = MealRecord(
            id: originalMeal.id,
            timestamp: now,
            mealType: MealType.breakfast,
            items: [updatedItem],
            notes: "Tô lớn đặc biệt",
            imagePath: "pho"
        )

        await vm.updateMeal(updatedMeal)

        // Verify state is updated and daily totals recalculated
        XCTAssertEqual(vm.totalCalories, 600)
        XCTAssertEqual(vm.totalProtein, 35)
        XCTAssertEqual(vm.filteredDayMeals.first?.displayTitle, "Phở Gà Đặc Biệt")
    }

    func testMealDeletionAndAggregatesSync() async {
        let now = Date()
        let meal1 = makeSampleMeal(name: "Bánh Cuốn", category: MealType.breakfast, timestamp: now, calories: 350)
        let meal2 = makeSampleMeal(name: "Gỏi Cuốn", category: MealType.lunch, timestamp: now, calories: 250)

        let repo = MockMealRepository(initialMeals: [meal1, meal2])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()
        XCTAssertEqual(vm.allDayMeals.count, 2)
        XCTAssertEqual(vm.totalCalories, 600)

        // Delete meal1
        await vm.deleteMeal(id: meal1.id)

        XCTAssertEqual(vm.allDayMeals.count, 1)
        XCTAssertEqual(vm.totalCalories, 250)
        XCTAssertEqual(vm.allDayMeals.first?.id, meal2.id)
    }

    func testQuickAddFromVietnameseDatabase() async {
        let repo = MockMealRepository(initialMeals: [])
        let useCase = GetMealHistoryUseCase(mealRepository: repo)
        let vm = MealHistoryViewModel(getMealHistoryUseCase: useCase)

        await vm.loadHistory()
        XCTAssertEqual(vm.allDayMeals.count, 0)

        // Pick dish from database
        let phoProfile = VietnameseNutritionDatabase.dishes.first { $0.slug == "pho" }!
        await vm.quickAdd(dish: phoProfile, category: MealType.breakfast, servingGrams: 450)

        XCTAssertEqual(vm.allDayMeals.count, 1)
        let addedMeal = vm.allDayMeals.first!
        XCTAssertEqual(addedMeal.mealType, MealType.breakfast)
        XCTAssertEqual(addedMeal.items.first?.vietnameseName, phoProfile.vietnameseName)
        XCTAssertEqual(addedMeal.totalCalories, Double(phoProfile.caloriesPerServing))
    }
}
