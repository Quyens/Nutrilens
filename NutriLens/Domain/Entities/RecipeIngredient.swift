//
//  RecipeIngredient.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents an ingredient line-item within a recipe.
//

import Foundation

public enum IngredientSourceType: String, Codable, Equatable, Hashable, Sendable {
    case vietnameseDatabase
    case customFood
    case manual
}

public struct RecipeIngredient: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var sourceType: IngredientSourceType
    public var sourceReferenceId: String?
    public var amountGrams: Double
    public var grams: Double {
        get { amountGrams }
        set { amountGrams = newValue }
    }
    public var servingUnit: String
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double
    public var notes: String?

    public init(
        id: UUID = UUID(),
        name: String,
        sourceType: IngredientSourceType = .manual,
        sourceReferenceId: String? = nil,
        amountGrams: Double,
        servingUnit: String = "g",
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sourceType = sourceType
        self.sourceReferenceId = sourceReferenceId
        self.amountGrams = max(amountGrams, 1.0)
        self.servingUnit = servingUnit
        self.calories = max(calories, 0)
        self.proteinGrams = max(proteinGrams, 0)
        self.carbGrams = max(carbGrams, 0)
        self.fatGrams = max(fatGrams, 0)
        self.fiberGrams = max(fiberGrams, 0)
        self.notes = notes
    }

    /// Creates an ingredient from a standard Vietnamese database dish
    public static func fromVietnameseDish(_ dish: VietnameseDishProfile, amountGrams: Double) -> RecipeIngredient {
        let ratio = max(amountGrams, 1.0) / max(dish.standardServingGrams, 1.0)
        return RecipeIngredient(
            id: UUID(),
            name: dish.vietnameseName,
            sourceType: .vietnameseDatabase,
            sourceReferenceId: dish.slug,
            amountGrams: amountGrams,
            servingUnit: "g",
            calories: (dish.caloriesPerServing * ratio).rounded(),
            proteinGrams: ((dish.proteinPerServing * ratio) * 10).rounded() / 10,
            carbGrams: ((dish.carbPerServing * ratio) * 10).rounded() / 10,
            fatGrams: ((dish.fatPerServing * ratio) * 10).rounded() / 10,
            fiberGrams: ((dish.fiberPerServing * ratio) * 10).rounded() / 10,
            notes: dish.category
        )
    }

    public static func fromVietnameseDish(_ dish: VietnameseDishProfile, grams: Double) -> RecipeIngredient {
        fromVietnameseDish(dish, amountGrams: grams)
    }

    /// Creates an ingredient from a saved CustomFood
    public static func fromCustomFood(_ food: CustomFood, amountGrams: Double) -> RecipeIngredient {
        let ratio = max(amountGrams, 1.0) / max(food.servingSizeGrams, 1.0)
        return RecipeIngredient(
            id: UUID(),
            name: food.name,
            sourceType: .customFood,
            sourceReferenceId: food.id.uuidString,
            amountGrams: amountGrams,
            servingUnit: food.servingUnit,
            calories: (food.calories * ratio).rounded(),
            proteinGrams: ((food.proteinGrams * ratio) * 10).rounded() / 10,
            carbGrams: ((food.carbGrams * ratio) * 10).rounded() / 10,
            fatGrams: ((food.fatGrams * ratio) * 10).rounded() / 10,
            fiberGrams: ((food.fiberGrams * ratio) * 10).rounded() / 10,
            notes: food.category
        )
    }

    public static func fromCustomFood(_ food: CustomFood, grams: Double) -> RecipeIngredient {
        fromCustomFood(food, amountGrams: grams)
    }
}
