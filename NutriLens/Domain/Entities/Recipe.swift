//
//  Recipe.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a user recipe composed of multiple ingredients with calculated nutrition.
//

import Foundation

public struct Recipe: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var servings: Int
    public var prepTimeMinutes: Int?
    public var cookingTimeMinutes: Int?
    public var cookTimeMinutes: Int? {
        get { cookingTimeMinutes }
        set { cookingTimeMinutes = newValue }
    }
    public var ingredients: [RecipeIngredient]
    public var instructions: [String]
    public var notes: String?
    public var isFavorite: Bool
    public var imagePath: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        servings: Int = 2,
        prepTimeMinutes: Int? = 15,
        cookingTimeMinutes: Int? = 20,
        ingredients: [RecipeIngredient] = [],
        instructions: [String] = [],
        notes: String? = nil,
        isFavorite: Bool = false,
        imagePath: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.servings = max(servings, 1)
        self.prepTimeMinutes = prepTimeMinutes
        self.cookingTimeMinutes = cookingTimeMinutes
        self.ingredients = ingredients
        self.instructions = instructions
        self.notes = notes
        self.isFavorite = isFavorite
        self.imagePath = imagePath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var totalTimeMinutes: Int {
        (prepTimeMinutes ?? 0) + (cookingTimeMinutes ?? 0)
    }

    // MARK: - Combined Recipe Totals
    public var totalCalories: Double {
        ingredients.reduce(0) { $0 + $1.calories }
    }

    public var totalProteinGrams: Double {
        let sum = ingredients.reduce(0) { $0 + $1.proteinGrams }
        return (sum * 10).rounded() / 10
    }

    public var totalCarbGrams: Double {
        let sum = ingredients.reduce(0) { $0 + $1.carbGrams }
        return (sum * 10).rounded() / 10
    }

    public var totalFatGrams: Double {
        let sum = ingredients.reduce(0) { $0 + $1.fatGrams }
        return (sum * 10).rounded() / 10
    }

    public var totalFiberGrams: Double {
        let sum = ingredients.reduce(0) { $0 + $1.fiberGrams }
        return (sum * 10).rounded() / 10
    }

    public var totalWeightGrams: Double {
        ingredients.reduce(0) { $0 + $1.amountGrams }
    }

    // MARK: - Per-Serving Nutrition
    public var perServingCalories: Double {
        guard servings > 0 else { return 0 }
        return (totalCalories / Double(servings)).rounded()
    }

    public var perServingProteinGrams: Double {
        guard servings > 0 else { return 0 }
        return ((totalProteinGrams / Double(servings) * 10).rounded()) / 10
    }

    public var perServingCarbGrams: Double {
        guard servings > 0 else { return 0 }
        return ((totalCarbGrams / Double(servings) * 10).rounded()) / 10
    }

    public var perServingFatGrams: Double {
        guard servings > 0 else { return 0 }
        return ((totalFatGrams / Double(servings) * 10).rounded()) / 10
    }

    public var perServingFiberGrams: Double {
        guard servings > 0 else { return 0 }
        return ((totalFiberGrams / Double(servings) * 10).rounded()) / 10
    }

    public var perServingWeightGrams: Double {
        guard servings > 0 else { return 0 }
        return (totalWeightGrams / Double(servings)).rounded()
    }

    public var standardServingGrams: Double {
        perServingWeightGrams > 0 ? perServingWeightGrams : 200.0
    }

    public var perServingNutrition: RecipeNutritionSnapshot {
        RecipeNutritionSnapshot(
            calories: perServingCalories,
            proteinGrams: perServingProteinGrams,
            carbGrams: perServingCarbGrams,
            fatGrams: perServingFatGrams,
            fiberGrams: perServingFiberGrams,
            weightGrams: perServingWeightGrams
        )
    }

    // MARK: - Scaled Nutrition for Arbitrary Serving Count
    public func scaledNutrition(forServings targetServings: Double) -> RecipeNutritionSnapshot {
        let safeTarget = max(targetServings, 0.1)
        return RecipeNutritionSnapshot(
            calories: (perServingCalories * safeTarget).rounded(),
            proteinGrams: ((perServingProteinGrams * safeTarget * 10).rounded()) / 10,
            carbGrams: ((perServingCarbGrams * safeTarget * 10).rounded()) / 10,
            fatGrams: ((perServingFatGrams * safeTarget * 10).rounded()) / 10,
            fiberGrams: ((perServingFiberGrams * safeTarget * 10).rounded()) / 10,
            weightGrams: (perServingWeightGrams * safeTarget).rounded()
        )
    }

    // MARK: - Independent Meal Diary Snapshot
    public func toFoodItem(servingCount: Double = 1.0) -> FoodItem {
        let scaled = scaledNutrition(forServings: servingCount)
        let titleSuffix = servingCount == 1.0 ? " (1 phần)" : " (\(String(format: "%.1f", servingCount)) phần)"
        return FoodItem(
            id: UUID(), // Independent UUID
            name: name + titleSuffix,
            vietnameseName: name + titleSuffix,
            confidence: 1.0,
            servingSizeGrams: scaled.weightGrams,
            calories: scaled.calories,
            proteinGrams: scaled.proteinGrams,
            carbGrams: scaled.carbGrams,
            fatGrams: scaled.fatGrams,
            fiberGrams: scaled.fiberGrams
        )
    }
}

// MARK: - Recipe Nutrition Snapshot
public struct RecipeNutritionSnapshot: Equatable, Hashable, Sendable {
    public let calories: Double
    public let proteinGrams: Double
    public let carbGrams: Double
    public let fatGrams: Double
    public let fiberGrams: Double
    public let weightGrams: Double

    public init(
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double,
        weightGrams: Double
    ) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.weightGrams = weightGrams
    }
}
