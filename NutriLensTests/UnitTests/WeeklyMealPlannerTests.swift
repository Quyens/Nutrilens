//
//  WeeklyMealPlannerTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Comprehensive automated test suite for Weekly Meal Planner (Phase 04).
//

import XCTest
import SwiftData
@testable import NutriLens

final class WeeklyMealPlannerTests: XCTestCase {
    private var calendarHelper: MealPlanCalendarHelper!
    private var mockMealPlanRepo: MockMealPlanRepository!
    private var mockMealRepo: MockMealRepository!
    private var logPlannedMealUseCase: LogPlannedMealToDiaryUseCase!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        cal.firstWeekday = 2 // Monday
        calendarHelper = MealPlanCalendarHelper(calendar: cal)

        mockMealPlanRepo = MockMealPlanRepository(initialMeals: [], seedInitial: false, calendarHelper: calendarHelper)
        mockMealRepo = MockMealRepository()
        logPlannedMealUseCase = LogPlannedMealToDiaryUseCase(
            mealPlanRepository: mockMealPlanRepo,
            mealRepository: mockMealRepo
        )
    }

    override func tearDown() {
        calendarHelper = nil
        mockMealPlanRepo = nil
        mockMealRepo = nil
        logPlannedMealUseCase = nil
        super.tearDown()
    }

    // 1. Weekly date range calculation (Monday 00:00 to Sunday 23:59)
    func testWeeklyDateRangeCalculation() {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 11
        comps.day = 11 // Wednesday
        let wednesday = calendarHelper.calendar.date(from: comps)!

        let monday = calendarHelper.startOfWeek(for: wednesday)
        let mondayWeekday = calendarHelper.calendar.component(.weekday, from: monday)
        XCTAssertEqual(mondayWeekday, 2, "Start of week must be Monday (weekday 2)")

        let days = calendarHelper.daysOfWeek(for: wednesday)
        XCTAssertEqual(days.count, 7, "A week must contain exactly 7 calendar days")
        XCTAssertTrue(calendarHelper.isSameDay(days[0], monday), "First day must be Monday")
    }

    // 2. Previous and next week navigation
    func testWeekNavigation() {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 11
        comps.day = 10
        let date = calendarHelper.calendar.date(from: comps)!

        let nextWeek = calendarHelper.addingWeeks(1, to: date)
        let prevWeek = calendarHelper.addingWeeks(-1, to: date)

        let diffNext = calendarHelper.calendar.dateComponents([.day], from: date, to: nextWeek).day
        let diffPrev = calendarHelper.calendar.dateComponents([.day], from: prevWeek, to: date).day

        XCTAssertEqual(diffNext, 7, "Advancing by 1 week must add 7 days")
        XCTAssertEqual(diffPrev, 7, "Rewinding by 1 week must subtract 7 days")
    }

    // 3. Calendar boundary cases (Month transition & Year transition)
    func testCalendarBoundaryCases() {
        // Month transition: October 30 to November 2, 2026
        var octComps = DateComponents()
        octComps.year = 2026
        octComps.month = 10
        octComps.day = 31 // Saturday
        let oct31 = calendarHelper.calendar.date(from: octComps)!
        let days = calendarHelper.daysOfWeek(for: oct31)
        XCTAssertEqual(days.count, 7)

        // Year transition: December 31, 2026 to January 1, 2027
        var decComps = DateComponents()
        decComps.year = 2026
        decComps.month = 12
        decComps.day = 31 // Thursday
        let dec31 = calendarHelper.calendar.date(from: decComps)!
        let decDays = calendarHelper.daysOfWeek(for: dec31)
        XCTAssertEqual(decDays.count, 7)
    }

    // 4. Creating planned meals
    func testCreatePlannedMeal() async throws {
        let date = Date()
        let dish = VietnameseNutritionDatabase.dishes.first!
        let item = PlannedFoodItem.fromVietnameseDish(dish, quantityGrams: 400)

        let meal = PlannedMeal(
            scheduledDate: date,
            mealCategory: .breakfast,
            foodItems: [item],
            notes: "Bữa sáng tràn đầy năng lượng"
        )

        let saveUseCase = SavePlannedMealUseCase(repository: mockMealPlanRepo)
        try await saveUseCase.execute(meal)

        let fetched = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.mealCategory, .breakfast)
        XCTAssertEqual(fetched?.foodItems.count, 1)
        XCTAssertEqual(fetched?.foodItems.first?.displayName, dish.vietnameseName)
    }

    // 5. Updating planned meals
    func testUpdatePlannedMeal() async throws {
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .lunch,
            foodItems: [
                PlannedFoodItem(
                    sourceType: .manual,
                    displayName: "Cơm trắng",
                    quantity: 150,
                    servingUnit: "g",
                    nutritionSnapshot: PlannedNutritionSnapshot(calories: 195, proteinGrams: 4, carbGrams: 42, fatGrams: 0.5)
                )
            ]
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)

        var updated = meal
        updated.notes = "Thêm canh chua"
        updated.mealCategory = .dinner
        try await mockMealPlanRepo.updatePlannedMeal(updated)

        let fetched = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertEqual(fetched?.notes, "Thêm canh chua")
        XCTAssertEqual(fetched?.mealCategory, .dinner)
    }

    // 6. Deleting planned meals
    func testDeletePlannedMeal() async throws {
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .snack,
            foodItems: [
                PlannedFoodItem(
                    sourceType: .manual,
                    displayName: "Trái cây",
                    quantity: 100,
                    nutritionSnapshot: PlannedNutritionSnapshot(calories: 50)
                )
            ]
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)
        let savedMeal = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertNotNil(savedMeal)

        let deleteUseCase = DeletePlannedMealUseCase(repository: mockMealPlanRepo)
        try await deleteUseCase.execute(id: meal.id)

        let fetched = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertNil(fetched, "Meal must be completely deleted")
    }

    // 7. Planned nutrition calculations
    func testPlannedNutritionCalculations() {
        let item1 = PlannedFoodItem(
            sourceType: .manual,
            displayName: "Món 1",
            quantity: 100,
            nutritionSnapshot: PlannedNutritionSnapshot(calories: 200, proteinGrams: 10, carbGrams: 30, fatGrams: 4, fiberGrams: 2)
        )
        let item2 = PlannedFoodItem(
            sourceType: .manual,
            displayName: "Món 2",
            quantity: 100,
            nutritionSnapshot: PlannedNutritionSnapshot(calories: 300, proteinGrams: 20, carbGrams: 15, fatGrams: 12, fiberGrams: 3)
        )

        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .lunch,
            foodItems: [item1, item2]
        )

        let total = meal.totalNutrition
        XCTAssertEqual(total.calories, 500)
        XCTAssertEqual(total.proteinGrams, 30.0)
        XCTAssertEqual(total.carbGrams, 45.0)
        XCTAssertEqual(total.fatGrams, 16.0)
        XCTAssertEqual(total.fiberGrams, 5.0)
    }

    // 8. Source nutrition snapshot integrity
    func testSourceNutritionSnapshotIntegrity() {
        let dish = VietnameseNutritionDatabase.dishes.first!
        let item = PlannedFoodItem.fromVietnameseDish(dish, quantityGrams: dish.standardServingGrams * 2)

        XCTAssertEqual(item.quantity, dish.standardServingGrams * 2)
        XCTAssertEqual(item.nutritionSnapshot.calories, (dish.caloriesPerServing * 2).rounded())
        XCTAssertEqual(item.toFoodItem().calories, item.nutritionSnapshot.calories)
    }

    // 9. Adding CustomFood to a plan
    func testAddCustomFoodToPlan() {
        let customFood = CustomFood(
            name: "Sữa chua Hy Lạp Granola",
            servingUnit: "hũ",
            servingSizeGrams: 150,
            calories: 180,
            proteinGrams: 15,
            carbGrams: 20,
            fatGrams: 4
        )

        let plannedItem = PlannedFoodItem.fromCustomFood(customFood, quantityGrams: 300)
        XCTAssertEqual(plannedItem.sourceType, PlannedFoodSourceType.customFood)
        XCTAssertEqual(plannedItem.quantity, 300)
        XCTAssertEqual(plannedItem.nutritionSnapshot.calories, 360)
        XCTAssertEqual(plannedItem.nutritionSnapshot.proteinGrams, 30)
    }

    // 10. Adding Recipe to a plan
    func testAddRecipeToPlan() {
        let ingredient = RecipeIngredient(
            name: "Ức gà",
            amountGrams: 200,
            calories: 330,
            proteinGrams: 62,
            carbGrams: 0,
            fatGrams: 7
        )
        let recipe = Recipe(
            name: "Ức gà áp chảo",
            servings: 2,
            ingredients: [ingredient]
        )

        let plannedItem = PlannedFoodItem.fromRecipe(recipe, servings: 1.0)
        XCTAssertEqual(plannedItem.sourceType, PlannedFoodSourceType.recipe)
        XCTAssertEqual(plannedItem.nutritionSnapshot.calories, 165) // 330 / 2
        XCTAssertEqual(plannedItem.nutritionSnapshot.proteinGrams, 31) // 62 / 2
    }

    // 11. Copying a day's plan (Append & Replace)
    func testCopyDayPlan() async throws {
        let today = calendarHelper.startOfDay(for: Date())
        let tomorrow = calendarHelper.calendar.date(byAdding: .day, value: 1, to: today)!

        let meal1 = PlannedMeal(
            scheduledDate: today,
            mealCategory: .breakfast,
            foodItems: [PlannedFoodItem(sourceType: .manual, displayName: "Phở", quantity: 400, nutritionSnapshot: .init(calories: 450))]
        )
        let meal2 = PlannedMeal(
            scheduledDate: today,
            mealCategory: .lunch,
            foodItems: [PlannedFoodItem(sourceType: .manual, displayName: "Cơm", quantity: 300, nutritionSnapshot: .init(calories: 500))]
        )
        try await mockMealPlanRepo.savePlannedMeal(meal1)
        try await mockMealPlanRepo.savePlannedMeal(meal2)

        let copyUseCase = CopyDayPlanUseCase(repository: mockMealPlanRepo, calendarHelper: calendarHelper)

        // Append mode
        let copiedCount = try await copyUseCase.execute(from: today, to: tomorrow, mode: .append)
        XCTAssertEqual(copiedCount, 2)

        let tomorrowMeals = try await mockMealPlanRepo.getPlannedMeals(forDay: tomorrow)
        XCTAssertEqual(tomorrowMeals.count, 2)
        XCTAssertNotEqual(tomorrowMeals.first?.id, meal1.id, "Copied meals must have distinct stable UUIDs")
        XCTAssertEqual(tomorrowMeals.first?.status, .planned, "Copied meal status must be reset to planned")

        // Replace mode
        let dayAfterTomorrow = calendarHelper.calendar.date(byAdding: .day, value: 2, to: today)!
        let existingMeal = PlannedMeal(
            scheduledDate: dayAfterTomorrow,
            mealCategory: .dinner,
            foodItems: [PlannedFoodItem(sourceType: .manual, displayName: "Bún", quantity: 300, nutritionSnapshot: .init(calories: 400))]
        )
        try await mockMealPlanRepo.savePlannedMeal(existingMeal)

        let replacedCount = try await copyUseCase.execute(from: today, to: dayAfterTomorrow, mode: .replace)
        XCTAssertEqual(replacedCount, 2)

        let dayAfterMeals = try await mockMealPlanRepo.getPlannedMeals(forDay: dayAfterTomorrow)
        XCTAssertEqual(dayAfterMeals.count, 2)
        XCTAssertFalse(dayAfterMeals.contains(where: { $0.id == existingMeal.id }), "Existing meals must be replaced")
    }

    // 12. Duplicating planned meals
    func testDuplicateMeal() {
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .lunch,
            foodItems: [
                PlannedFoodItem(sourceType: .manual, displayName: "Cá kho", quantity: 150, nutritionSnapshot: .init(calories: 250))
            ],
            notes: "Ngon tuyệt"
        )

        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let duplicated = meal.duplicate(forDate: nextDay)

        XCTAssertNotEqual(duplicated.id, meal.id)
        XCTAssertEqual(duplicated.scheduledDate, nextDay)
        XCTAssertEqual(duplicated.notes, "Ngon tuyệt")
        XCTAssertEqual(duplicated.foodItems.count, 1)
        XCTAssertEqual(duplicated.status, .planned)
        XCTAssertNil(duplicated.linkedDiaryRecordId)
    }

    // 13. Marking meals skipped & restoring
    func testMarkSkippedAndRestore() async throws {
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .dinner,
            foodItems: [PlannedFoodItem(sourceType: .manual, displayName: "Salad", quantity: 200, nutritionSnapshot: .init(calories: 120))]
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)

        let statusUseCase = MarkPlannedMealStatusUseCase(repository: mockMealPlanRepo)

        try await statusUseCase.markSkipped(mealId: meal.id)
        var fetched = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertEqual(fetched?.status, .skipped)

        try await statusUseCase.restorePlanned(mealId: meal.id)
        fetched = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertEqual(fetched?.status, .planned)
    }

    // 14. Diary integration (Atomic log to diary + mark completed)
    func testLogPlannedMealToDiary() async throws {
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .lunch,
            foodItems: [
                PlannedFoodItem(sourceType: .manual, displayName: "Cơm tấm", quantity: 350, nutritionSnapshot: .init(calories: 620, proteinGrams: 35))
            ]
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)

        let loggedRecord = try await logPlannedMealUseCase.execute(
            plannedMeal: meal,
            actualFoodItems: nil,
            loggedDate: Date(),
            mealType: .lunch,
            notes: "Ăn trưa no nê"
        )

        XCTAssertEqual(loggedRecord.mealType, .lunch)
        XCTAssertEqual(loggedRecord.items.count, 1)
        XCTAssertEqual(loggedRecord.items.first?.calories, 620)

        // Verify planned meal was marked completed and linked
        let updatedPlanned = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
        XCTAssertEqual(updatedPlanned?.status, .completed)
        XCTAssertEqual(updatedPlanned?.linkedDiaryRecordId, loggedRecord.id)

        // Verify meal exists in actual diary repository
        let diaryMeals = try await mockMealRepo.fetchAllMeals()
        XCTAssertTrue(diaryMeals.contains(where: { $0.id == loggedRecord.id }))
    }

    // 15. Duplicate logging prevention
    func testPreventDuplicateDiaryLogging() async throws {
        let existingDiaryId = UUID()
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .breakfast,
            foodItems: [PlannedFoodItem(sourceType: .manual, displayName: "Bánh mì", quantity: 150, nutritionSnapshot: .init(calories: 380))],
            status: .completed,
            linkedDiaryRecordId: existingDiaryId
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)

        do {
            try await logPlannedMealUseCase.execute(
                plannedMeal: meal,
                actualFoodItems: nil,
                loggedDate: Date(),
                mealType: .breakfast,
                notes: nil
            )
            XCTFail("Should throw duplicateEntry error")
        } catch {
            // Success: duplicate logging prevented
            XCTAssertTrue(error is AppError)
        }
    }

    // 16. Failed diary persistence rollback
    func testFailedDiaryPersistenceRollback() async throws {
        // Create an invalid meal item to cause LogMealUseCase or repository to fail if empty
        let meal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .breakfast,
            foodItems: [] // Empty items will cause failure
        )
        try await mockMealPlanRepo.savePlannedMeal(meal)

        do {
            try await logPlannedMealUseCase.execute(
                plannedMeal: meal,
                actualFoodItems: [],
                loggedDate: Date(),
                mealType: .breakfast,
                notes: nil
            )
            XCTFail("Must fail on empty food items")
        } catch {
            let plannedAfter = try await mockMealPlanRepo.getPlannedMeal(byId: meal.id)
            XCTAssertEqual(plannedAfter?.status, .planned, "Status must remain untouched if saving diary fails")
            XCTAssertNil(plannedAfter?.linkedDiaryRecordId)
        }
    }

    // 17. SwiftData persistence test
    @MainActor
    func testSwiftDataPersistence() throws {
        let schema = Schema([
            MealSDModel.self,
            FoodItemSDModel.self,
            HydrationRecordSDModel.self,
            CustomFoodSDModel.self,
            RecipeSDModel.self,
            RecipeIngredientSDModel.self,
            PlannedMealSDModel.self,
            PlannedFoodItemSDModel.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let domainFood = PlannedFoodItem(
            sourceType: .vietnameseDatabase,
            sourceId: "pho",
            displayName: "Phở Bò Tái Nạm",
            quantity: 450,
            servingUnit: "g",
            portionMultiplier: 1.0,
            nutritionSnapshot: PlannedNutritionSnapshot(calories: 480, proteinGrams: 32, carbGrams: 58, fatGrams: 12, fiberGrams: 4)
        )
        let domainMeal = PlannedMeal(
            scheduledDate: Date(),
            mealCategory: .breakfast,
            foodItems: [domainFood],
            notes: "Ăn phở nóng buổi sáng",
            status: .planned
        )

        let model = PlannedMealSDModel(from: domainMeal)
        context.insert(model)
        try context.save()

        let descriptor = FetchDescriptor<PlannedMealSDModel>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)

        let reconstructed = fetched.first?.toDomain()
        XCTAssertEqual(reconstructed?.id, domainMeal.id)
        XCTAssertEqual(reconstructed?.mealCategory, .breakfast)
        XCTAssertEqual(reconstructed?.foodItems.count, 1)
        XCTAssertEqual(reconstructed?.foodItems.first?.displayName, "Phở Bò Tái Nạm")
        XCTAssertEqual(reconstructed?.totalCalories, 480)
    }
}
