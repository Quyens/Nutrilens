//
//  MealLoggingV2Tests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 02 Recovery: Verifies multi-item manual meal logging, Vietnamese search,
//  portion calculation, custom inline items, SwiftData hydration persistence,
//  unit formatting, and haptic preferences.
//

import XCTest
import UIKit
@testable import NutriLens

@MainActor
final class MealLoggingV2Tests: XCTestCase {

    private var mockMealRepository: MockMealRepository!
    private var mockHydrationRepository: MockHydrationRepository!
    private var logMealUseCase: LogMealUseCase!
    private var addHydrationUseCase: AddHydrationUseCase!
    private var getDailyHydrationUseCase: GetDailyHydrationUseCase!
    private var getHydrationHistoryUseCase: GetHydrationHistoryUseCase!
    private var deleteHydrationUseCase: DeleteHydrationUseCase!

    override func setUp() async throws {
        mockMealRepository = MockMealRepository(initialMeals: [])
        mockHydrationRepository = MockHydrationRepository()
        logMealUseCase = LogMealUseCase(mealRepository: mockMealRepository)
        addHydrationUseCase = AddHydrationUseCase(repository: mockHydrationRepository)
        getDailyHydrationUseCase = GetDailyHydrationUseCase(repository: mockHydrationRepository)
        getHydrationHistoryUseCase = GetHydrationHistoryUseCase(repository: mockHydrationRepository)
        deleteHydrationUseCase = DeleteHydrationUseCase(repository: mockHydrationRepository)
    }

    override func tearDown() async throws {
        mockMealRepository = nil
        mockHydrationRepository = nil
        logMealUseCase = nil
        addHydrationUseCase = nil
        getDailyHydrationUseCase = nil
        getHydrationHistoryUseCase = nil
        deleteHydrationUseCase = nil
        UserDefaults.standard.removeObject(forKey: "useMetricUnits")
        UserDefaults.standard.removeObject(forKey: "hapticFeedbackEnabled")
    }

    // MARK: - 1. Multi-Item Staging & Live Nutrition Aggregation

    func testInitialStagedItemsAreEmpty() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        XCTAssertTrue(vm.stagedItems.isEmpty)
        XCTAssertEqual(vm.totalCalories, 0)
        XCTAssertEqual(vm.totalProtein, 0)
        XCTAssertEqual(vm.totalCarbs, 0)
        XCTAssertEqual(vm.totalFat, 0)
        XCTAssertFalse(vm.canSave)
    }

    func testAddSingleFoodItemToMeal() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let sample = VietnameseNutritionDatabase.dishes[0]

        vm.addDishFromDatabase(sample, grams: sample.standardServingGrams)

        XCTAssertEqual(vm.stagedItems.count, 1)
        XCTAssertEqual(vm.stagedItems.first?.name, sample.vietnameseName)
        XCTAssertEqual(vm.totalCalories, sample.caloriesPerServing)
        XCTAssertEqual(vm.totalProtein, sample.proteinPerServing)
        XCTAssertEqual(vm.totalCarbs, sample.carbPerServing)
        XCTAssertEqual(vm.totalFat, sample.fatPerServing)
        XCTAssertTrue(vm.canSave)
    }

    func testAddMultipleFoodItemsAggregatesTotals() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let dishes = VietnameseNutritionDatabase.dishes
        guard dishes.count >= 2 else {
            XCTFail("Catalogue should have at least 2 dishes")
            return
        }

        let dish1 = dishes[0]
        let dish2 = dishes[1]

        vm.addDishFromDatabase(dish1, grams: dish1.standardServingGrams)
        vm.addDishFromDatabase(dish2, grams: dish2.standardServingGrams)

        XCTAssertEqual(vm.stagedItems.count, 2)
        let expectedCalories = dish1.caloriesPerServing + dish2.caloriesPerServing
        let expectedProtein = dish1.proteinPerServing + dish2.proteinPerServing
        let expectedCarbs = dish1.carbPerServing + dish2.carbPerServing
        let expectedFat = dish1.fatPerServing + dish2.fatPerServing

        XCTAssertEqual(vm.totalCalories, expectedCalories, accuracy: 0.1)
        XCTAssertEqual(vm.totalProtein, expectedProtein, accuracy: 0.1)
        XCTAssertEqual(vm.totalCarbs, expectedCarbs, accuracy: 0.1)
        XCTAssertEqual(vm.totalFat, expectedFat, accuracy: 0.1)
    }

    func testRemoveItemUpdatesMealTotals() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let dishes = VietnameseNutritionDatabase.dishes
        let dish1 = dishes[0]
        let dish2 = dishes[1]

        vm.addDishFromDatabase(dish1, grams: dish1.standardServingGrams)
        vm.addDishFromDatabase(dish2, grams: dish2.standardServingGrams)
        XCTAssertEqual(vm.stagedItems.count, 2)

        let firstId = vm.stagedItems[0].id
        vm.removeItem(id: firstId)

        XCTAssertEqual(vm.stagedItems.count, 1)
        XCTAssertEqual(vm.stagedItems[0].name, dish2.vietnameseName)
        XCTAssertEqual(vm.totalCalories, dish2.caloriesPerServing, accuracy: 0.1)
    }

    func testPortionScalingUpdatesNutrition() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let dish = VietnameseNutritionDatabase.dishes[0]

        // Add 1.5x portion by grams
        let targetGrams = dish.standardServingGrams * 1.5
        vm.addDishFromDatabase(dish, grams: targetGrams)

        XCTAssertEqual(vm.stagedItems.count, 1)
        guard let item = vm.stagedItems.first else { return }

        XCTAssertEqual(item.portionGrams, targetGrams, accuracy: 0.1)
        XCTAssertEqual(item.calories, (dish.caloriesPerServing * 1.5).rounded(), accuracy: 0.1)
        XCTAssertEqual(item.proteinGrams, ((dish.proteinPerServing * 1.5) * 10).rounded() / 10, accuracy: 0.1)

        // Update portion on existing item to 2.0x
        let doubleGrams = dish.standardServingGrams * 2.0
        vm.updateItemPortion(id: item.id, newGrams: doubleGrams)
        let updated = vm.stagedItems.first!
        XCTAssertEqual(updated.portionGrams, doubleGrams, accuracy: 0.1)
        XCTAssertEqual(updated.calories, (dish.caloriesPerServing * 2.0).rounded(), accuracy: 0.1)
    }

    // MARK: - 2. Vietnamese Diacritic-Insensitive Search

    func testVietnameseDiacriticInsensitiveSearch() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)

        // Search with no accents "pho bo" should match "Phở Bò..."
        vm.searchQuery = "pho bo"
        XCTAssertFalse(vm.filteredCatalogDishes.isEmpty)
        let compareOptions: NSString.CompareOptions = [.diacriticInsensitive, .caseInsensitive]
        XCTAssertTrue(vm.filteredCatalogDishes.allSatisfy {
            $0.vietnameseName.folding(options: compareOptions, locale: Locale(identifier: "vi_VN"))
                .contains("pho bo")
        })

        // Search with accents "Cơm Tấm"
        vm.searchQuery = "Cơm Tấm"
        XCTAssertFalse(vm.filteredCatalogDishes.isEmpty)
        XCTAssertTrue(vm.filteredCatalogDishes.allSatisfy {
            $0.vietnameseName.folding(options: compareOptions, locale: Locale(identifier: "vi_VN"))
                .contains("com tam")
        })

        // Empty search restores full catalogue
        vm.searchQuery = ""
        XCTAssertEqual(vm.filteredCatalogDishes.count, VietnameseNutritionDatabase.dishes.count)
    }

    // MARK: - 3. Inline Custom Food Creation

    func testAddInlineCustomFood() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)

        vm.customName = "Bánh Mì Heo Quay Nhà Làm"
        vm.customPortionGramsText = "220"
        vm.customCaloriesText = "480"
        vm.customProteinText = "22"
        vm.customCarbsText = "52"
        vm.customFatText = "18"
        vm.customFiberText = "3"

        vm.addCustomItem()

        XCTAssertEqual(vm.stagedItems.count, 1)
        let item = vm.stagedItems[0]
        XCTAssertEqual(item.name, "Bánh Mì Heo Quay Nhà Làm")
        XCTAssertEqual(item.portionGrams, 220)
        XCTAssertEqual(item.calories, 480)
        XCTAssertEqual(item.proteinGrams, 22)
        XCTAssertEqual(item.carbGrams, 52)
        XCTAssertEqual(item.fatGrams, 18)
        XCTAssertEqual(item.fiberGrams, 3)
        XCTAssertEqual(vm.totalCalories, 480)
        XCTAssertTrue(item.isCustom)
    }

    // MARK: - 4. Meal Date, Meal Type & Persistence

    func testSaveMultiItemMealWithHistoricalDateAndCategory() async throws {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let dish1 = VietnameseNutritionDatabase.dishes[0]
        let dish2 = VietnameseNutritionDatabase.dishes[1]

        vm.addDishFromDatabase(dish1, grams: dish1.standardServingGrams)
        vm.addDishFromDatabase(dish2, grams: dish2.standardServingGrams)

        let historicalDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        vm.selectedDate = historicalDate
        vm.selectedMealType = MealType.dinner
        vm.mealNotes = "Bữa tối gia đình sum họp"

        let savedSuccess = await vm.saveMealAsync()
        XCTAssertTrue(savedSuccess)

        let allMeals = try await mockMealRepository.fetchAllMeals()
        XCTAssertEqual(allMeals.count, 1)

        guard let savedMeal = allMeals.first else {
            XCTFail("Meal should have been persisted")
            return
        }

        XCTAssertEqual(savedMeal.mealType, MealType.dinner)
        XCTAssertEqual(savedMeal.notes, "Bữa tối gia đình sum họp")
        XCTAssertEqual(savedMeal.items.count, 2)
        XCTAssertEqual(savedMeal.totalCalories, dish1.caloriesPerServing + dish2.caloriesPerServing, accuracy: 0.1)

        let diff = abs(savedMeal.timestamp.timeIntervalSince(historicalDate))
        XCTAssertLessThan(diff, 1.0)
    }

    func testPreventAccidentalDuplicateSubmission() {
        let vm = LogMealViewModel(logMealUseCase: logMealUseCase)
        let dish = VietnameseNutritionDatabase.dishes[0]
        vm.addDishFromDatabase(dish, grams: dish.standardServingGrams)

        XCTAssertTrue(vm.canSave)
    }

    // MARK: - 5. SwiftData Hydration Persistence & History

    func testAddHydrationUseCaseValidation() async {
        do {
            _ = try await addHydrationUseCase.execute(amountLiters: -0.5, timestamp: Date(), notes: nil)
            XCTFail("Should have thrown error for negative water amount")
        } catch let AppError.invalidInput(msg) {
            XCTAssertTrue(msg.contains("Lượng nước uống phải lớn hơn 0"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testAddHydrationAndCalculateDailyTotals() async throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        _ = try await addHydrationUseCase.execute(amountLiters: 0.25, timestamp: today, notes: "Sáng sớm")
        _ = try await addHydrationUseCase.execute(amountLiters: 0.50, timestamp: today, notes: "Trưa")
        _ = try await addHydrationUseCase.execute(amountLiters: 0.35, timestamp: yesterday, notes: "Hôm qua")

        let todaySummary = try await getDailyHydrationUseCase.execute(for: today)
        XCTAssertEqual(todaySummary.totalLiters, 0.75, accuracy: 0.001)
        XCTAssertEqual(todaySummary.records.count, 2)

        let yesterdaySummary = try await getDailyHydrationUseCase.execute(for: yesterday)
        XCTAssertEqual(yesterdaySummary.totalLiters, 0.35, accuracy: 0.001)
        XCTAssertEqual(yesterdaySummary.records.count, 1)

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let tomorrowSummary = try await getDailyHydrationUseCase.execute(for: tomorrow)
        XCTAssertEqual(tomorrowSummary.totalLiters, 0.0)
        XCTAssertTrue(tomorrowSummary.records.isEmpty)
    }

    func testDeleteHydrationRecord() async throws {
        let record = try await addHydrationUseCase.execute(amountLiters: 0.3, timestamp: Date(), notes: "Nước lọc")
        let beforeSummary = try await getDailyHydrationUseCase.execute(for: Date())
        XCTAssertEqual(beforeSummary.totalLiters, 0.3, accuracy: 0.001)

        try await deleteHydrationUseCase.execute(id: record.id)
        let afterSummary = try await getDailyHydrationUseCase.execute(for: Date())
        XCTAssertEqual(afterSummary.totalLiters, 0.0, accuracy: 0.001)
    }

    func testLegacyUserDefaultsHydrationMigration() async throws {
        UserDefaults.standard.removeObject(forKey: "nutrilens_hydration_migrated_v2")
        let today = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy_MM_dd"
        let legacyKey = "nutrilens_water_intake_\(formatter.string(from: today))"

        UserDefaults.standard.set(0.65, forKey: legacyKey)
        defer {
            UserDefaults.standard.removeObject(forKey: legacyKey)
            UserDefaults.standard.removeObject(forKey: "nutrilens_hydration_migrated_v2")
        }

        let repo = HydrationRepository()
        try await repo.migrateLegacyUserDefaultsIfNeeded()

        let remaining = UserDefaults.standard.double(forKey: legacyKey)
        XCTAssertEqual(remaining, 0.0, "Legacy key should be migrated and removed")
    }

    // MARK: - 6. Unit Formatting Service

    func testUnitFormattingMetricAndImperial() {
        UserDefaults.standard.set(true, forKey: "useMetricUnits")
        let metricService = UnitFormattingService()
        XCTAssertTrue(metricService.isMetric)
        XCTAssertEqual(metricService.formatWeight(grams: 100), "100 g")
        XCTAssertEqual(metricService.formatVolume(liters: 0.25), "250 ml")
        XCTAssertEqual(metricService.formatVolume(liters: 1.5), "1.5 L")

        UserDefaults.standard.set(false, forKey: "useMetricUnits")
        let imperialService = UnitFormattingService()
        XCTAssertFalse(imperialService.isMetric)
        let imperialWeight = imperialService.formatWeight(grams: 100)
        XCTAssertTrue(imperialWeight.contains("oz"))

        let imperialLiquid = imperialService.formatVolume(liters: 0.5)
        XCTAssertTrue(imperialLiquid.contains("fl oz"))
    }

    // MARK: - 7. Haptic Feedback Service

    func testHapticFeedbackPreferenceGating() {
        UserDefaults.standard.set(true, forKey: "hapticFeedbackEnabled")
        let enabledService = HapticFeedbackService()
        XCTAssertTrue(enabledService.isHapticsEnabled)
        enabledService.impact(.medium)
        enabledService.notification(.success)
        enabledService.selection()

        UserDefaults.standard.set(false, forKey: "hapticFeedbackEnabled")
        let disabledService = HapticFeedbackService()
        XCTAssertFalse(disabledService.isHapticsEnabled)
        disabledService.impact(.heavy)
        disabledService.notification(.error)
        disabledService.selection()
    }
}
