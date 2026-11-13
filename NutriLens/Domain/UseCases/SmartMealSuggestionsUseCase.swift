//
//  SmartMealSuggestionsUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Coordinates recommendation generation, safety checking, and weekly planner addition.
//

import Foundation

public protocol SmartMealSuggestionsUseCaseProtocol: Sendable {
    func getSuggestions(filter: SmartSuggestionsFilter, targetDate: Date) async throws -> [MealSuggestion]
    func getDietaryProfile() async throws -> UserDietaryProfile
    func saveDietaryProfile(_ profile: UserDietaryProfile) async throws
    func clearDietaryProfile() async throws
    func toggleFavorite(suggestion: MealSuggestion) async throws -> Bool
    func addSuggestionToWeeklyPlan(
        suggestion: MealSuggestion,
        targetDate: Date,
        mealCategory: PlannedMealCategory,
        servingMultiplier: Double,
        notes: String?
    ) async throws -> PlannedMeal
}

public final class SmartMealSuggestionsUseCase: SmartMealSuggestionsUseCaseProtocol, @unchecked Sendable {
    private let userDietaryProfileRepository: UserDietaryProfileRepositoryProtocol
    private let foodFavoritesRepository: FoodFavoritesRepositoryProtocol
    private let customFoodRepository: CustomFoodRepositoryProtocol
    private let recipeRepository: RecipeRepositoryProtocol
    private let mealPlanRepository: MealPlanRepositoryProtocol
    private let mealRepository: MealRepositoryProtocol
    private let engine: SmartMealSuggestionEngine
    private let calendarHelper: MealPlanCalendarHelper

    public init(
        userDietaryProfileRepository: UserDietaryProfileRepositoryProtocol,
        foodFavoritesRepository: FoodFavoritesRepositoryProtocol,
        customFoodRepository: CustomFoodRepositoryProtocol,
        recipeRepository: RecipeRepositoryProtocol,
        mealPlanRepository: MealPlanRepositoryProtocol,
        mealRepository: MealRepositoryProtocol,
        engine: SmartMealSuggestionEngine = SmartMealSuggestionEngine(),
        calendar: Calendar = .current
    ) {
        self.userDietaryProfileRepository = userDietaryProfileRepository
        self.foodFavoritesRepository = foodFavoritesRepository
        self.customFoodRepository = customFoodRepository
        self.recipeRepository = recipeRepository
        self.mealPlanRepository = mealPlanRepository
        self.mealRepository = mealRepository
        self.engine = engine
        self.calendarHelper = MealPlanCalendarHelper(calendar: calendar)
    }

    public func getSuggestions(filter: SmartSuggestionsFilter, targetDate: Date) async throws -> [MealSuggestion] {
        // 1. Load User Dietary Profile
        let profile = try await userDietaryProfileRepository.getDietaryProfile()

        // 2. Load User Favorites (synchronous on FoodFavoritesRepositoryProtocol)
        let favoriteIds = foodFavoritesRepository.getFavoriteIds()

        // 3. Load Vietnamese Dishes
        let vietnameseDishes = VietnameseNutritionDatabase.dishes

        // 4. Load Custom Foods & Recipes
        let customFoods = (try? await customFoodRepository.fetchAllCustomFoods()) ?? []
        let recipes = (try? await recipeRepository.fetchAllRecipes()) ?? []

        // 5. Load Meal Diary History for recency & variety
        let allMeals = (try? await mealRepository.fetchAllMeals()) ?? []
        let recentDishNames = allMeals.prefix(30).flatMap { $0.items.map { $0.vietnameseName } }

        let todayMeals = (try? await mealRepository.fetchMeals(for: targetDate)) ?? []
        let todayDiaryDishNames = todayMeals.flatMap { $0.items.map { $0.vietnameseName } }

        // 6. Load Planned Meals for the week
        let weekStart = calendarHelper.startOfWeek(for: targetDate)
        let weekEnd = calendarHelper.endOfWeek(for: targetDate)
        let weekPlannedMeals = (try? await mealPlanRepository.getPlannedMeals(forWeekStarting: weekStart, weekEndDate: weekEnd)) ?? []
        let weekPlannedDishNames = weekPlannedMeals.flatMap { $0.foodItems.map { $0.displayName } }

        let todayPlannedMeals = (try? await mealPlanRepository.getPlannedMeals(forDay: targetDate)) ?? []
        let todayPlannedDishNames = todayPlannedMeals.flatMap { $0.foodItems.map { $0.displayName } }

        // 7. Build Recommendation Context
        let context = RecommendationContext(
            targetDate: targetDate,
            targetCategory: filter.mealCategory,
            userProfile: profile,
            favoriteIds: favoriteIds,
            recentDiaryDishNames: recentDishNames,
            todayDiaryDishNames: todayDiaryDishNames,
            plannedDishNamesThisWeek: weekPlannedDishNames,
            todayPlannedDishNames: todayPlannedDishNames
        )

        // 8. Run Deterministic Scoring Engine
        let suggestions = engine.rankSuggestions(
            vietnameseDishes: vietnameseDishes,
            customFoods: customFoods,
            recipes: recipes,
            filter: filter,
            context: context
        )

        return suggestions
    }

    public func getDietaryProfile() async throws -> UserDietaryProfile {
        try await userDietaryProfileRepository.getDietaryProfile()
    }

    public func saveDietaryProfile(_ profile: UserDietaryProfile) async throws {
        try await userDietaryProfileRepository.saveDietaryProfile(profile)
    }

    public func clearDietaryProfile() async throws {
        try await userDietaryProfileRepository.clearDietaryProfile()
    }

    public func toggleFavorite(suggestion: MealSuggestion) async throws -> Bool {
        switch suggestion.foodSource {
        case .vietnameseDatabase:
            if let id = suggestion.sourceId {
                return foodFavoritesRepository.toggleFavorite(id: id)
            }
            return false

        case .customFood:
            if let uuidString = suggestion.sourceId, let uuid = UUID(uuidString: uuidString) {
                try await customFoodRepository.toggleFavorite(id: uuid)
                let food = try await customFoodRepository.fetchCustomFood(id: uuid)
                return food?.isFavorite ?? false
            }
            return false

        case .recipe:
            if let uuidString = suggestion.sourceId, let uuid = UUID(uuidString: uuidString) {
                try await recipeRepository.toggleFavorite(id: uuid)
                let recipe = try await recipeRepository.fetchRecipe(id: uuid)
                return recipe?.isFavorite ?? false
            }
            return false

        case .packagedFood:
            return false

        case .manual:
            return false
        }
    }

    public func addSuggestionToWeeklyPlan(
        suggestion: MealSuggestion,
        targetDate: Date,
        mealCategory: PlannedMealCategory,
        servingMultiplier: Double,
        notes: String?
    ) async throws -> PlannedMeal {
        let validMultiplier = max(0.25, min(5.0, servingMultiplier))

        let scaledSnapshot = PlannedNutritionSnapshot(
            calories: suggestion.availableNutritionEstimate.calories * validMultiplier,
            proteinGrams: suggestion.availableNutritionEstimate.proteinGrams * validMultiplier,
            carbGrams: suggestion.availableNutritionEstimate.carbGrams * validMultiplier,
            fatGrams: suggestion.availableNutritionEstimate.fatGrams * validMultiplier,
            fiberGrams: suggestion.availableNutritionEstimate.fiberGrams * validMultiplier
        )

        let scaledGrams = suggestion.suggestedServingGrams * validMultiplier

        let foodItem = PlannedFoodItem(
            sourceType: suggestion.foodSource,
            sourceId: suggestion.sourceId,
            displayName: suggestion.displayName,
            quantity: scaledGrams,
            servingUnit: "g",
            portionMultiplier: validMultiplier,
            nutritionSnapshot: scaledSnapshot
        )

        // Check if there is already a planned meal for this category & day
        let sameDayMeals = try await mealPlanRepository.getPlannedMeals(forDay: targetDate)
        let sameDayCategoryMeals = sameDayMeals.filter { $0.mealCategory == mealCategory }

        if var existingMeal = sameDayCategoryMeals.first {
            existingMeal.foodItems.append(foodItem)
            if let notes, !notes.isEmpty {
                if let exNotes = existingMeal.notes, !exNotes.isEmpty {
                    existingMeal.notes = "\(exNotes) • \(notes)"
                } else {
                    existingMeal.notes = notes
                }
            }
            existingMeal.updatedAt = Date()
            try await mealPlanRepository.updatePlannedMeal(existingMeal)
            return existingMeal
        } else {
            let newMeal = PlannedMeal(
                scheduledDate: targetDate,
                mealCategory: mealCategory,
                foodItems: [foodItem],
                notes: notes,
                status: .planned
            )
            try await mealPlanRepository.savePlannedMeal(newMeal)
            return newMeal
        }
    }
}
