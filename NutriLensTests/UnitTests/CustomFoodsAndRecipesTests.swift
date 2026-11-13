//
//  CustomFoodsAndRecipesTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Test Suite: Custom Foods, Recipes, Micronutrients, SwiftData persistence,
//  nutrition scaling, snapshot independence, and multi-source logging.
//

import XCTest
import SwiftData
@testable import NutriLens

@MainActor
final class CustomFoodsAndRecipesTests: XCTestCase {

    private var mockFoodRepo: MockCustomFoodRepository!
    private var mockRecipeRepo: MockRecipeRepository!
    private var mockMealRepo: MockMealRepository!
    private var getCustomFoodsUseCase: GetCustomFoodsUseCase!
    private var saveCustomFoodUseCase: SaveCustomFoodUseCase!
    private var deleteCustomFoodUseCase: DeleteCustomFoodUseCase!
    private var getRecipesUseCase: GetRecipesUseCase!
    private var saveRecipeUseCase: SaveRecipeUseCase!
    private var deleteRecipeUseCase: DeleteRecipeUseCase!
    private var calculateRecipeNutritionUseCase: CalculateRecipeNutritionUseCase!
    private var logMealUseCase: LogMealUseCase!

    override func setUp() async throws {
        mockFoodRepo = MockCustomFoodRepository()
        mockRecipeRepo = MockRecipeRepository()
        mockMealRepo = MockMealRepository(initialMeals: [])

        getCustomFoodsUseCase = GetCustomFoodsUseCase(repository: mockFoodRepo)
        saveCustomFoodUseCase = SaveCustomFoodUseCase(repository: mockFoodRepo)
        deleteCustomFoodUseCase = DeleteCustomFoodUseCase(repository: mockFoodRepo)

        getRecipesUseCase = GetRecipesUseCase(repository: mockRecipeRepo)
        saveRecipeUseCase = SaveRecipeUseCase(repository: mockRecipeRepo)
        deleteRecipeUseCase = DeleteRecipeUseCase(repository: mockRecipeRepo)

        calculateRecipeNutritionUseCase = CalculateRecipeNutritionUseCase()
        logMealUseCase = LogMealUseCase(mealRepository: mockMealRepo)
    }

    override func tearDown() async throws {
        mockFoodRepo = nil
        mockRecipeRepo = nil
        mockMealRepo = nil
        getCustomFoodsUseCase = nil
        saveCustomFoodUseCase = nil
        deleteCustomFoodUseCase = nil
        getRecipesUseCase = nil
        saveRecipeUseCase = nil
        deleteRecipeUseCase = nil
        calculateRecipeNutritionUseCase = nil
        logMealUseCase = nil
    }

    // MARK: - 1. CustomFood Entity & Nutrition Calculations

    func testCustomFoodScaledNutrition() {
        let food = CustomFood(
            name: "Ức gà luộc",
            category: "Món Mặn",
            servingUnit: "g",
            servingSizeGrams: 100,
            calories: 165,
            proteinGrams: 31.0,
            carbGrams: 0.0,
            fatGrams: 3.6,
            fiberGrams: 0.0
        )

        // Scale to 200g (2x)
        let scaled200 = food.scaled(to: 200)
        XCTAssertEqual(scaled200.servingSizeGrams, 200)
        XCTAssertEqual(scaled200.calories, 330)
        XCTAssertEqual(scaled200.proteinGrams, 62.0)
        XCTAssertEqual(scaled200.carbGrams, 0.0)
        XCTAssertEqual(scaled200.fatGrams, 7.2)

        // Scale to 50g (0.5x)
        let scaled50 = food.scaled(to: 50)
        XCTAssertEqual(scaled50.calories, 83.0) // 165 * 0.5 rounded = 83 or 82.5 rounded
        XCTAssertEqual(scaled50.proteinGrams, 15.5)
    }

    func testCustomFoodPer100gProjections() {
        // A serving of 150g containing 300 kcal
        let food = CustomFood(
            name: "Bánh bông lan",
            servingUnit: "cái",
            servingSizeGrams: 150,
            calories: 300,
            proteinGrams: 6.0,
            carbGrams: 45.0,
            fatGrams: 10.5
        )

        // Per 100g should be 300 / 150 * 100 = 200 kcal
        XCTAssertEqual(food.caloriesPer100g, 200)
        XCTAssertEqual(food.proteinPer100g, 4.0)
        XCTAssertEqual(food.carbPer100g, 30.0)
        XCTAssertEqual(food.fatPer100g, 7.0)
    }

    // MARK: - 2. MicronutrientProfile Combination & Scaling

    func testMicronutrientProfileScalingAndAdditiveCombination() {
        let micro1 = MicronutrientProfile(
            sodiumMg: 200,
            potassiumMg: 300,
            calciumMg: 50,
            ironMg: 2.0,
            vitaminAMcg: 100,
            vitaminCMg: 15.0,
            sugarGrams: 5.0,
            cholesterolMg: 25
        )

        // Scale 1.5x
        let scaled = micro1.scaled(by: 1.5)
        XCTAssertEqual(scaled.sodiumMg, 300)
        XCTAssertEqual(scaled.potassiumMg, 450)
        XCTAssertEqual(scaled.calciumMg, 75)
        XCTAssertEqual(scaled.ironMg, 3.0)
        XCTAssertEqual(scaled.vitaminAMcg, 150)
        XCTAssertEqual(scaled.vitaminCMg, 22.5)

        // Additive combine with micro2
        let micro2 = MicronutrientProfile(
            sodiumMg: 150,
            potassiumMg: nil, // Unknown
            calciumMg: 30,
            ironMg: 1.5
        )

        let combined = micro1 + micro2
        XCTAssertEqual(combined.sodiumMg, 350) // 200 + 150
        XCTAssertEqual(combined.potassiumMg, 300) // Preserves non-nil
        XCTAssertEqual(combined.calciumMg, 80) // 50 + 30
        XCTAssertEqual(combined.ironMg, 3.5) // 2.0 + 1.5
        XCTAssertEqual(combined.sugarGrams, 5.0) // Preserved
    }

    // MARK: - 3. Recipe Ingredients & Construction

    func testRecipeIngredientFromVietnameseDish() {
        guard let pho = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "pho" }) else {
            XCTFail("Pho dish profile not found")
            return
        }

        // Standard Pho Bo serving
        let ing = RecipeIngredient.fromVietnameseDish(pho, amountGrams: pho.standardServingGrams)
        XCTAssertEqual(ing.name, pho.vietnameseName)
        XCTAssertEqual(ing.sourceType, .vietnameseDatabase)
        XCTAssertEqual(ing.sourceReferenceId, pho.slug)
        XCTAssertEqual(ing.amountGrams, pho.standardServingGrams)
        XCTAssertEqual(ing.calories, pho.caloriesPerServing)
        XCTAssertEqual(ing.proteinGrams, pho.proteinPerServing)
    }

    func testRecipeIngredientFromCustomFood() {
        let custom = CustomFood(
            name: "Sốt bơ đậu phộng",
            servingUnit: "muỗng",
            servingSizeGrams: 30,
            calories: 180,
            proteinGrams: 8.0,
            carbGrams: 6.0,
            fatGrams: 16.0
        )

        // Use 60g in recipe (2 servings)
        let ing = RecipeIngredient.fromCustomFood(custom, amountGrams: 60)
        XCTAssertEqual(ing.name, "Sốt bơ đậu phộng")
        XCTAssertEqual(ing.sourceType, .customFood)
        XCTAssertEqual(ing.amountGrams, 60)
        XCTAssertEqual(ing.calories, 360) // 180 * 2
        XCTAssertEqual(ing.proteinGrams, 16.0)
        XCTAssertEqual(ing.fatGrams, 32.0)
    }

    // MARK: - 4. Recipe Live Aggregation & Servings Scaler

    func testRecipeNutritionCalculationAndServingsScaling() {
        let ing1 = RecipeIngredient(
            name: "Gạo lứt",
            sourceType: .manual,
            amountGrams: 150,
            calories: 165,
            proteinGrams: 3.5,
            carbGrams: 34.5,
            fatGrams: 1.3
        )
        let ing2 = RecipeIngredient(
            name: "Ức gà",
            sourceType: .manual,
            amountGrams: 200,
            calories: 330,
            proteinGrams: 62.0,
            carbGrams: 0.0,
            fatGrams: 7.2
        )
        let ing3 = RecipeIngredient(
            name: "Bông cải xanh",
            sourceType: .manual,
            amountGrams: 100,
            calories: 35,
            proteinGrams: 2.8,
            carbGrams: 7.2,
            fatGrams: 0.4
        )

        let recipe = Recipe(
            name: "Cơm gà bông cải healthy",
            servings: 2,
            prepTimeMinutes: 10,
            cookingTimeMinutes: 20,
            ingredients: [ing1, ing2, ing3]
        )

        // Total pot nutrition
        let expectedTotalCal = 165.0 + 330.0 + 35.0 // 530.0
        let expectedTotalWeight = 150.0 + 200.0 + 100.0 // 450.0
        XCTAssertEqual(recipe.totalCalories, expectedTotalCal)
        XCTAssertEqual(recipe.totalWeightGrams, expectedTotalWeight)

        // Per serving (2 servings)
        XCTAssertEqual(recipe.perServingCalories, 265.0) // 530 / 2
        XCTAssertEqual(recipe.perServingWeightGrams, 225.0) // 450 / 2
        XCTAssertEqual(recipe.perServingProteinGrams, 34.2) // (3.5 + 62.0 + 2.8) / 2 = 68.3 / 2 = 34.15 rounded = 34.2

        // Scale to 4 servings
        let scaled4 = recipe.scaledNutrition(forServings: 4.0)
        XCTAssertEqual(scaled4.calories, 1060.0) // 265 * 4
        XCTAssertEqual(scaled4.weightGrams, 900.0) // 225 * 4
    }

    func testCalculateRecipeNutritionUseCase() {
        let ing = RecipeIngredient(
            name: "Yến mạch",
            sourceType: .manual,
            amountGrams: 100,
            calories: 389,
            proteinGrams: 16.9,
            carbGrams: 66.3,
            fatGrams: 6.9,
            fiberGrams: 10.6
        )

        let summary = calculateRecipeNutritionUseCase.execute(ingredients: [ing], servings: 2)
        XCTAssertEqual(summary.totalCalories, 389)
        XCTAssertEqual(summary.servings, 2)
        XCTAssertEqual(summary.perServingCalories, 195.0) // 389 / 2 = 194.5 rounded to 195
        XCTAssertEqual(summary.perServingProteinGrams, 8.5) // 16.9 / 2 = 8.45 rounded to 8.5
    }

    // MARK: - 5. Validation Use Cases

    func testSaveCustomFoodValidationFailsForEmptyName() async {
        let invalidFood = CustomFood(
            name: "   ",
            servingSizeGrams: 100,
            calories: 100,
            proteinGrams: 10,
            carbGrams: 10,
            fatGrams: 2
        )

        do {
            try await saveCustomFoodUseCase.execute(invalidFood)
            XCTFail("Should have thrown error for empty name")
        } catch AppError.invalidInput {
            // Expected validation failure
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSaveRecipeValidationFailsForEmptyIngredients() async {
        let emptyRecipe = Recipe(
            name: "Công thức rỗng",
            servings: 2,
            ingredients: []
        )

        do {
            try await saveRecipeUseCase.execute(emptyRecipe)
            XCTFail("Should have thrown error for empty ingredients")
        } catch AppError.invalidInput {
            // Expected validation failure
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - 6. Snapshot Independence (Critical Clean Architecture Requirement)

    func testCustomFoodSnapshotIndependenceInMealDiary() async throws {
        // Create custom food
        var food = CustomFood(
            name: "Sinh tố chuối yến mạch",
            servingUnit: "ly",
            servingSizeGrams: 250,
            calories: 220,
            proteinGrams: 6.0,
            carbGrams: 42.0,
            fatGrams: 3.5
        )
        try await saveCustomFoodUseCase.execute(food)

        // Snapshot to FoodItem and log to diary
        let diarySnapshot = food.toFoodItem()
        let meal = MealRecord(
            timestamp: Date(),
            mealType: .breakfast,
            items: [diarySnapshot]
        )
        try await logMealUseCase.execute(meal: meal)

        // Now modify the original custom food drastically
        food.name = "Sinh tố chuối yến mạch (ĐỔI CÔNG THỨC)"
        food.calories = 500
        food.proteinGrams = 20.0
        try await saveCustomFoodUseCase.execute(food)

        // Verify the logged diary entry remains UNCHANGED (historical integrity)
        let loggedMeals = try await mockMealRepo.fetchAllMeals()
        XCTAssertEqual(loggedMeals.count, 1)
        let loggedItem = loggedMeals[0].items[0]
        XCTAssertEqual(loggedItem.name, "Sinh tố chuối yến mạch")
        XCTAssertEqual(loggedItem.calories, 220.0, "Historical diary calories must remain untouched!")
        XCTAssertEqual(loggedItem.proteinGrams, 6.0)
    }

    func testRecipeSnapshotIndependenceInMealDiary() async throws {
        let ing = RecipeIngredient(name: "Trứng gà", sourceType: .manual, amountGrams: 100, calories: 155, proteinGrams: 13, carbGrams: 1.1, fatGrams: 11)
        var recipe = Recipe(name: "Trứng chiên thảo mộc", servings: 1, ingredients: [ing])
        try await saveRecipeUseCase.execute(recipe)

        // Log 1 serving snapshot to diary
        let diarySnapshot = recipe.toFoodItem(servingCount: 1.0)
        let meal = MealRecord(
            timestamp: Date(),
            mealType: .dinner,
            items: [diarySnapshot]
        )
        try await logMealUseCase.execute(meal: meal)

        // Delete the original recipe completely
        try await deleteRecipeUseCase.execute(id: recipe.id)
        let remainingRecipes = try await getRecipesUseCase.execute()
        XCTAssertFalse(remainingRecipes.contains { $0.id == recipe.id })

        // Historical diary entry must STILL exist with intact calories!
        let loggedMeals = try await mockMealRepo.fetchAllMeals()
        XCTAssertEqual(loggedMeals.count, 1)
        XCTAssertEqual(loggedMeals[0].items[0].calories, 155.0)
    }

    // MARK: - 7. Multi-Source Manual Meal Logger Integration

    func testLogMealViewModelMultiSourceStaging() async {
        let viewModel = LogMealViewModel(
            logMealUseCase: logMealUseCase,
            getCustomFoodsUseCase: getCustomFoodsUseCase,
            getRecipesUseCase: getRecipesUseCase,
            unitFormattingService: UnitFormattingService.shared,
            hapticFeedbackService: HapticFeedbackService.shared
        )

        // 1. Stage a Vietnamese DB dish (Phở Bò, 400g)
        guard let phoBo = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "pho" }) else {
            XCTFail("Pho Bo not found")
            return
        }
        viewModel.addDishFromDatabase(phoBo, grams: 400)

        // 2. Stage a Custom Food (Protein Shake, 300g)
        let customShake = CustomFood(
            name: "Protein Shake chuối",
            servingUnit: "ly",
            servingSizeGrams: 300,
            calories: 250,
            proteinGrams: 30.0,
            carbGrams: 20.0,
            fatGrams: 3.0
        )
        viewModel.addCustomFood(customShake, grams: 300)

        // 3. Stage a Recipe (Salad ức gà, 1 serving = 200g, 220 kcal)
        let saladIng = RecipeIngredient(name: "Ức gà", sourceType: .manual, amountGrams: 150, calories: 220, proteinGrams: 35, carbGrams: 0, fatGrams: 4)
        let recipe = Recipe(name: "Salad ức gà dưa leo", servings: 1, ingredients: [saladIng])
        viewModel.addRecipe(recipe, servings: 1.0)

        // Assert that all 3 sources coexist in the staged items tray
        XCTAssertEqual(viewModel.stagedItems.count, 3)
        XCTAssertEqual(viewModel.stagedItems[0].name, phoBo.vietnameseName)
        XCTAssertEqual(viewModel.stagedItems[1].name, "Protein Shake chuối")
        XCTAssertEqual(viewModel.stagedItems[2].name, "Salad ức gà dưa leo")

        // Assert aggregate totals
        let expectedTotalCalories = (phoBo.caloriesPerServing * (400.0 / phoBo.standardServingGrams)).rounded() + 250.0 + 220.0
        XCTAssertEqual(viewModel.totalCalories, expectedTotalCalories)
        XCTAssertTrue(viewModel.canSave)

        // Save the meal and verify persistence
        let saved = await viewModel.saveMealAsync()
        XCTAssertTrue(saved)

        let savedMeals = try? await mockMealRepo.fetchAllMeals()
        XCTAssertEqual(savedMeals?.count, 1)
        XCTAssertEqual(savedMeals?.first?.items.count, 3)
    }

    // MARK: - 8. Search & Favorites Filtering in ViewModel

    func testMyFoodsAndRecipesViewModelSearchAndFilters() async throws {
        let isolatedFoodRepo = MockCustomFoodRepository(initialFoods: [])
        let isolatedRecipeRepo = MockRecipeRepository(initialRecipes: [])

        let food1 = CustomFood(name: "Súp lơ xào bò", category: "Món Mặn", servingSizeGrams: 150, calories: 180, proteinGrams: 20, carbGrams: 8, fatGrams: 6, isFavorite: true)
        let food2 = CustomFood(name: "Chè đậu xanh hạt sen", category: "Tráng Miệng", servingSizeGrams: 200, calories: 250, proteinGrams: 6, carbGrams: 50, fatGrams: 2, isFavorite: false)
        try await isolatedFoodRepo.saveCustomFood(food1)
        try await isolatedFoodRepo.saveCustomFood(food2)

        let rec1 = Recipe(name: "Bún chả healthy", servings: 2, ingredients: [RecipeIngredient(name: "Thịt nạc", sourceType: .manual, amountGrams: 200, calories: 300, proteinGrams: 40, carbGrams: 0, fatGrams: 10)], isFavorite: true)
        try await isolatedRecipeRepo.saveRecipe(rec1)

        let vm = MyFoodsAndRecipesViewModel(
            getCustomFoodsUseCase: GetCustomFoodsUseCase(repository: isolatedFoodRepo),
            saveCustomFoodUseCase: SaveCustomFoodUseCase(repository: isolatedFoodRepo),
            deleteCustomFoodUseCase: DeleteCustomFoodUseCase(repository: isolatedFoodRepo),
            getRecipesUseCase: GetRecipesUseCase(repository: isolatedRecipeRepo),
            saveRecipeUseCase: SaveRecipeUseCase(repository: isolatedRecipeRepo),
            deleteRecipeUseCase: DeleteRecipeUseCase(repository: isolatedRecipeRepo),
            logMealUseCase: logMealUseCase
        )

        // Load
        vm.loadData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Filter favorites only
        vm.showFavoritesOnly = true
        XCTAssertEqual(vm.filteredCustomFoods.count, 1)
        XCTAssertEqual(vm.filteredCustomFoods.first?.name, "Súp lơ xào bò")

        // Search query
        vm.showFavoritesOnly = false
        vm.searchQuery = "đậu xanh"
        XCTAssertEqual(vm.filteredCustomFoods.count, 1)
        XCTAssertEqual(vm.filteredCustomFoods.first?.name, "Chè đậu xanh hạt sen")

        // Switching to recipes tab
        vm.selectedTab = .recipes
        vm.searchQuery = "bún chả"
        XCTAssertEqual(vm.filteredRecipes.count, 1)
        XCTAssertEqual(vm.filteredRecipes.first?.name, "Bún chả healthy")
    }
}
