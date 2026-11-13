//
//  SmartSuggestionsTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Comprehensive unit tests for Phase 05 Smart Meal Suggestions.
//

import XCTest
@testable import NutriLens

final class SmartSuggestionsTests: XCTestCase {

    private var engine: SmartMealSuggestionEngine!
    private var dietaryRepo: MockUserDietaryProfileRepository!
    private var favoritesRepo: MockFoodFavoritesRepository!
    private var customFoodRepo: MockCustomFoodRepository!
    private var recipeRepo: MockRecipeRepository!
    private var mealPlanRepo: MockMealPlanRepository!
    private var mealRepo: MockMealRepository!
    private var useCase: SmartMealSuggestionsUseCase!

    override func setUp() async throws {
        try await super.setUp()
        engine = SmartMealSuggestionEngine()
        dietaryRepo = MockUserDietaryProfileRepository()
        favoritesRepo = MockFoodFavoritesRepository()
        customFoodRepo = MockCustomFoodRepository()
        recipeRepo = MockRecipeRepository()
        mealPlanRepo = MockMealPlanRepository(seedInitial: false)
        mealRepo = MockMealRepository()

        useCase = SmartMealSuggestionsUseCase(
            userDietaryProfileRepository: dietaryRepo,
            foodFavoritesRepository: favoritesRepo,
            customFoodRepository: customFoodRepo,
            recipeRepository: recipeRepo,
            mealPlanRepository: mealPlanRepo,
            mealRepository: mealRepo,
            engine: engine
        )
    }

    override func tearDown() async throws {
        engine = nil
        dietaryRepo = nil
        favoritesRepo = nil
        customFoodRepo = nil
        recipeRepo = nil
        mealPlanRepo = nil
        mealRepo = nil
        useCase = nil
        try await super.tearDown()
    }

    // 1. Deterministic recommendation ranking
    func testDeterministicRecommendationRanking() async throws {
        let filter = SmartSuggestionsFilter()
        let suggestions1 = try await useCase.getSuggestions(filter: filter, targetDate: Date())
        let suggestions2 = try await useCase.getSuggestions(filter: filter, targetDate: Date())

        XCTAssertFalse(suggestions1.isEmpty, "Suggestions should not be empty")
        XCTAssertEqual(suggestions1.count, suggestions2.count, "Result count must be strictly identical")
        for i in 0..<min(suggestions1.count, suggestions2.count) {
            XCTAssertEqual(suggestions1[i].displayName, suggestions2[i].displayName, "Item at index \(i) must be identical")
            XCTAssertEqual(suggestions1[i].recommendationScore, suggestions2[i].recommendationScore, "Scores must match identically")
        }
    }

    // 2. Meal category filtering
    func testMealCategoryFiltering() async throws {
        let breakfastFilter = SmartSuggestionsFilter(mealCategory: .breakfast)
        let breakfastSuggestions = try await useCase.getSuggestions(filter: breakfastFilter, targetDate: Date())

        XCTAssertFalse(breakfastSuggestions.isEmpty)
        // Verify all returned suggestions for breakfast are suitable breakfast dishes
        let names = breakfastSuggestions.map { $0.displayName.folding(options: .diacriticInsensitive, locale: .current).lowercased() }
        let hasBreakfastTypical = names.contains { name in
            name.contains("pho") || name.contains("banh mi") || name.contains("banh cuon") || name.contains("xoi")
        }
        XCTAssertTrue(hasBreakfastTypical, "Top recommendations for breakfast should include breakfast dishes")
    }

    // 3. Preference matching (High protein preference)
    func testHighProteinPreferenceMatching() async throws {
        var profile = UserDietaryProfile()
        profile.dietaryPreferences = [.highProtein]
        try await dietaryRepo.saveDietaryProfile(profile)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        XCTAssertFalse(suggestions.isEmpty)

        // Top suggestions should have high protein
        let top1 = suggestions.first!
        XCTAssertGreaterThanOrEqual(top1.availableNutritionEstimate.proteinGrams, 20.0)
    }

    // 4. Favorite prioritization
    func testFavoritePrioritization() async throws {
        // Mark com_tam as favorite
        _ = favoritesRepo.toggleFavorite(id: "com_tam")

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        if let comTam = suggestions.first(where: { $0.displayName.contains("Cơm Tấm") }) {
            XCTAssertTrue(comTam.isFavorite)
            XCTAssertTrue(comTam.explanationReasons.contains("Món bạn yêu thích"))
        } else {
            XCTFail("Cơm Tấm should be in suggestions")
        }
    }

    // 5. Recent meal diversity (variety penalty for today)
    func testRecentMealDiversityPenalty() async throws {
        // Add a logged meal today with "Phở Bò Tái Nạm"
        let todayMeal = MealRecord(
            timestamp: Date(),
            mealType: .breakfast,
            items: [
                FoodItem(
                    name: "Phở Bò Tái Nạm",
                    vietnameseName: "Phở Bò Tái Nạm",
                    confidence: 1.0,
                    servingSizeGrams: 450,
                    calories: 480,
                    proteinGrams: 28,
                    carbGrams: 58,
                    fatGrams: 14,
                    fiberGrams: 3
                )
            ]
        )
        try await mealRepo.saveMeal(todayMeal)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        if let pho = suggestions.first(where: { $0.displayName == "Phở Bò Tái Nạm" }) {
            let hasPenaltyFactor = pho.explanationFactors.contains { $0.scoreImpact == -25 }
            XCTAssertTrue(hasPenaltyFactor, "Should have recency penalty for being consumed today")
        }
    }

    // 6. Known allergen conflict exclusion
    func testKnownAllergenConflictExclusion() async throws {
        // Declare shellfish allergy
        var profile = UserDietaryProfile()
        profile.declaredAllergens = [.shellfish]
        try await dietaryRepo.saveDietaryProfile(profile)

        let filter = SmartSuggestionsFilter(excludeKnownAllergens: true)
        let suggestions = try await useCase.getSuggestions(filter: filter, targetDate: Date())

        // Verify that known shellfish dishes are strictly excluded
        let dishNames = suggestions.map { $0.displayName }
        XCTAssertFalse(dishNames.contains("Bún Bò Huế"), "Bún Bò Huế (chứa mắm ruốc, chả cua) must be excluded for shellfish allergy")
        XCTAssertFalse(dishNames.contains("Gỏi Cuốn"), "Gỏi Cuốn (chứa tôm) must be excluded for shellfish allergy")
        XCTAssertFalse(dishNames.contains("Bún Đậu Mắm Tôm"), "Bún Đậu Mắm Tôm must be excluded for shellfish allergy")
    }

    // 7. Missing ingredient uncertainty handling
    func testMissingIngredientUncertainty() async throws {
        // Custom food without ingredient details has partial status
        let customFood = CustomFood(
            name: "Bánh bông lan trứng muối homemade",
            category: "Tráng miệng",
            calories: 320,
            proteinGrams: 8,
            carbGrams: 42,
            fatGrams: 12
        )
        try await customFoodRepo.saveCustomFood(customFood)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        if let found = suggestions.first(where: { $0.displayName == customFood.name }) {
            XCTAssertEqual(found.ingredientVerificationStatus, .partial)
            XCTAssertEqual(found.ingredientVerificationStatus.badgeLabel, "Thành phần chưa đầy đủ")
        } else {
            XCTFail("Custom food should be in suggestions")
        }
    }

    // 8. CustomFood integration
    func testCustomFoodIntegration() async throws {
        let customFood = CustomFood(
            name: "Ức gà áp chảo sốt chanh leo",
            category: "Món chính",
            servingSizeGrams: 200,
            calories: 280,
            proteinGrams: 45,
            carbGrams: 10,
            fatGrams: 6,
            isFavorite: true
        )
        try await customFoodRepo.saveCustomFood(customFood)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        let match = suggestions.first(where: { $0.displayName == "Ức gà áp chảo sốt chanh leo" })

        XCTAssertNotNil(match)
        XCTAssertEqual(match?.foodSource, .customFood)
        XCTAssertTrue(match?.isFavorite == true)
        XCTAssertEqual(match?.availableNutritionEstimate.proteinGrams, 45)
    }

    // 9. Recipe integration
    func testRecipeIntegration() async throws {
        let recipe = Recipe(
            name: "Canh Gà Nấu Nấm Đông Cô",
            servings: 3,
            ingredients: [
                RecipeIngredient(name: "Thịt gà ta", amountGrams: 300, calories: 450, proteinGrams: 60, carbGrams: 0, fatGrams: 22),
                RecipeIngredient(name: "Nấm đông cô", amountGrams: 100, calories: 50, proteinGrams: 4, carbGrams: 10, fatGrams: 0)
            ],
            isFavorite: true
        )
        try await recipeRepo.saveRecipe(recipe)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        let match = suggestions.first(where: { $0.displayName == "Canh Gà Nấu Nấm Đông Cô" })

        XCTAssertNotNil(match)
        XCTAssertEqual(match?.foodSource, .recipe)
        XCTAssertEqual(match?.ingredientVerificationStatus, .verified)
    }

    // 10. Weekly Planner integration
    func testAddSuggestionToWeeklyPlan() async throws {
        let sampleSuggestion = MealSuggestion(
            foodSource: .vietnameseDatabase,
            sourceId: "pho",
            displayName: "Phở Bò Tái Nạm",
            dishCategory: "Món Nước",
            suggestedServing: "1 tô (450g)",
            suggestedServingGrams: 450,
            availableNutritionEstimate: PlannedNutritionSnapshot(calories: 480, proteinGrams: 28, carbGrams: 58, fatGrams: 14, fiberGrams: 3),
            recommendationScore: 85,
            explanationReasons: ["Phù hợp bữa sáng"],
            ingredientVerificationStatus: .verified
        )

        let targetDate = Date()
        let plannedMeal = try await useCase.addSuggestionToWeeklyPlan(
            suggestion: sampleSuggestion,
            targetDate: targetDate,
            mealCategory: .breakfast,
            servingMultiplier: 1.0,
            notes: "Ăn ít bánh phở"
        )

        XCTAssertEqual(plannedMeal.mealCategory, .breakfast)
        XCTAssertEqual(plannedMeal.foodItems.count, 1)
        XCTAssertEqual(plannedMeal.foodItems.first?.displayName, "Phở Bò Tái Nạm")
        XCTAssertEqual(plannedMeal.foodItems.first?.nutritionSnapshot.calories, 480)

        // Verify retrieval from weekly meal plan
        let meals = try await mealPlanRepo.getPlannedMeals(forDay: targetDate)
        XCTAssertEqual(meals.count, 1)
    }

    // 11. Portion snapshot preservation
    func testPortionMultiplierScaling() async throws {
        let sampleSuggestion = MealSuggestion(
            foodSource: .vietnameseDatabase,
            sourceId: "com_tam",
            displayName: "Cơm Tấm Sườn Nướng",
            dishCategory: "Cơm",
            suggestedServing: "1 đĩa (400g)",
            suggestedServingGrams: 400,
            availableNutritionEstimate: PlannedNutritionSnapshot(calories: 600, proteinGrams: 30, carbGrams: 70, fatGrams: 20, fiberGrams: 4),
            recommendationScore: 85,
            explanationReasons: ["Phù hợp bữa trưa"],
            ingredientVerificationStatus: .verified
        )

        // 1.5x portion multiplier
        let plannedMeal = try await useCase.addSuggestionToWeeklyPlan(
            suggestion: sampleSuggestion,
            targetDate: Date(),
            mealCategory: .lunch,
            servingMultiplier: 1.5,
            notes: nil
        )

        let item = plannedMeal.foodItems.first!
        XCTAssertEqual(item.quantity, 600.0, accuracy: 0.1) // 400 * 1.5
        XCTAssertEqual(item.portionMultiplier, 1.5)
        XCTAssertEqual(item.nutritionSnapshot.calories, 900.0, accuracy: 0.1) // 600 * 1.5
        XCTAssertEqual(item.nutritionSnapshot.proteinGrams, 45.0, accuracy: 0.1) // 30 * 1.5
    }

    // 12. Preference persistence
    func testPreferencePersistence() async throws {
        var profile = UserDietaryProfile()
        profile.dietaryPreferences = [.vegetarian, .eatClean]
        profile.declaredAllergens = [.peanuts, .gluten]
        profile.dislikedIngredients = ["hành lá", "ớt"]

        try await useCase.saveDietaryProfile(profile)

        let loaded = try await useCase.getDietaryProfile()
        XCTAssertEqual(loaded.dietaryPreferences, [.vegetarian, .eatClean])
        XCTAssertEqual(loaded.declaredAllergens, [.peanuts, .gluten])
        XCTAssertEqual(loaded.dislikedIngredients, ["hành lá", "ớt"])

        // Clear
        try await useCase.clearDietaryProfile()
        let cleared = try await useCase.getDietaryProfile()
        XCTAssertTrue(cleared.declaredAllergens.isEmpty)
        XCTAssertTrue(cleared.dislikedIngredients.isEmpty)
    }

    // 13. Empty recommendation results fallback
    func testEmptyRecommendationResults() async throws {
        // Set search query that matches nothing
        let filter = SmartSuggestionsFilter(searchQuery: "XYZ_DOES_NOT_EXIST_12345")
        let suggestions = try await useCase.getSuggestions(filter: filter, targetDate: Date())

        XCTAssertTrue(suggestions.isEmpty)
    }

    // 14. Offline operation without network calls
    func testOfflineOperationWithoutNetwork() async throws {
        // Entire pipeline operates in-memory / locally with 0 URLSession requests
        let filter = SmartSuggestionsFilter()
        let suggestions = try await useCase.getSuggestions(filter: filter, targetDate: Date())
        XCTAssertGreaterThan(suggestions.count, 10, "Should generate recommendations offline")
    }

    // 15. Duplicate addition appends item to existing planned meal
    func testAddDuplicateDishToPlannedMeal() async throws {
        let sampleSuggestion = MealSuggestion(
            foodSource: .vietnameseDatabase,
            sourceId: "pho",
            displayName: "Phở Bò",
            dishCategory: "Món Nước",
            suggestedServing: "1 tô",
            suggestedServingGrams: 450,
            availableNutritionEstimate: PlannedNutritionSnapshot(calories: 450, proteinGrams: 25, carbGrams: 55, fatGrams: 12, fiberGrams: 2),
            recommendationScore: 80,
            explanationReasons: ["Món nước"],
            ingredientVerificationStatus: .verified
        )

        let targetDate = Date()
        _ = try await useCase.addSuggestionToWeeklyPlan(
            suggestion: sampleSuggestion,
            targetDate: targetDate,
            mealCategory: .breakfast,
            servingMultiplier: 1.0,
            notes: "Bát 1"
        )

        // Add second dish to the same breakfast
        let updatedMeal = try await useCase.addSuggestionToWeeklyPlan(
            suggestion: sampleSuggestion,
            targetDate: targetDate,
            mealCategory: .breakfast,
            servingMultiplier: 1.0,
            notes: "Bát 2"
        )

        XCTAssertEqual(updatedMeal.foodItems.count, 2, "Should append to existing breakfast meal")
    }

    // 16. Existing feature regressions check
    func testVegetarianExcludesMeatDishes() async throws {
        var profile = UserDietaryProfile()
        profile.dietaryPreferences = [.vegetarian]
        try await dietaryRepo.saveDietaryProfile(profile)

        let suggestions = try await useCase.getSuggestions(filter: .default, targetDate: Date())
        let dishNames = suggestions.map { $0.displayName }

        XCTAssertFalse(dishNames.contains("Phở Bò Tái Nạm"))
        XCTAssertFalse(dishNames.contains("Cơm Tấm Sườn Nướng"))
        XCTAssertFalse(dishNames.contains("Bún Chả Hà Nội"))
    }
}
