//
//  CustomFood.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a user-defined custom food item with full nutritional data.
//

import Foundation

public struct CustomFood: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var category: String
    public var brand: String?
    public var servingUnit: String
    public var servingSizeGrams: Double
    public var servingGrams: Double {
        get { servingSizeGrams }
        set { servingSizeGrams = newValue }
    }
    public var calories: Double
    public var caloriesPerServing: Double {
        get { calories }
        set { calories = newValue }
    }
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double
    public var micronutrients: MicronutrientProfile?
    public var notes: String?
    public var isFavorite: Bool
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        category: String = "Món chính",
        brand: String? = nil,
        servingUnit: String = "g",
        servingSizeGrams: Double = 100,
        servingGrams: Double? = nil,
        calories: Double = 0,
        caloriesPerServing: Double? = nil,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double = 0,
        micronutrients: MicronutrientProfile? = nil,
        notes: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.brand = brand
        self.servingUnit = servingUnit
        let actualGrams = servingGrams ?? servingSizeGrams
        self.servingSizeGrams = max(actualGrams, 1.0)
        let actualCalories = caloriesPerServing ?? calories
        self.calories = max(actualCalories, 0)
        self.proteinGrams = max(proteinGrams, 0)
        self.carbGrams = max(carbGrams, 0)
        self.fatGrams = max(fatGrams, 0)
        self.fiberGrams = max(fiberGrams, 0)
        self.micronutrients = micronutrients
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Per 100g Projections
    public var caloriesPer100g: Double {
        guard servingSizeGrams > 0 else { return 0 }
        return ((calories / servingSizeGrams) * 100).rounded()
    }

    public var proteinPer100g: Double {
        guard servingSizeGrams > 0 else { return 0 }
        return ((((proteinGrams / servingSizeGrams) * 100) * 10).rounded()) / 10
    }

    public var carbPer100g: Double {
        guard servingSizeGrams > 0 else { return 0 }
        return ((((carbGrams / servingSizeGrams) * 100) * 10).rounded()) / 10
    }

    public var fatPer100g: Double {
        guard servingSizeGrams > 0 else { return 0 }
        return ((((fatGrams / servingSizeGrams) * 100) * 10).rounded()) / 10
    }

    public var fiberPer100g: Double {
        guard servingSizeGrams > 0 else { return 0 }
        return ((((fiberGrams / servingSizeGrams) * 100) * 10).rounded()) / 10
    }

    // MARK: - Portion Scaling
    public func scaled(to targetGrams: Double) -> CustomFood {
        guard servingSizeGrams > 0 else { return self }
        let ratio = max(targetGrams, 1.0) / servingSizeGrams
        var updated = self
        updated.servingSizeGrams = targetGrams
        updated.calories = (calories * ratio).rounded()
        updated.proteinGrams = ((proteinGrams * ratio * 10).rounded()) / 10
        updated.carbGrams = ((carbGrams * ratio * 10).rounded()) / 10
        updated.fatGrams = ((fatGrams * ratio * 10).rounded()) / 10
        updated.fiberGrams = ((fiberGrams * ratio * 10).rounded()) / 10
        updated.micronutrients = micronutrients?.scaled(by: ratio)
        return updated
    }

    // MARK: - Snapshot Conversion for Meal Diary
    public func toFoodItem(portionGrams: Double? = nil) -> FoodItem {
        let grams = portionGrams ?? servingSizeGrams
        let scaledItem = scaled(to: grams)
        return FoodItem(
            id: UUID(), // Fresh independent ID for the meal snapshot
            name: name,
            vietnameseName: name,
            confidence: 1.0,
            servingSizeGrams: scaledItem.servingSizeGrams,
            calories: scaledItem.calories,
            proteinGrams: scaledItem.proteinGrams,
            carbGrams: scaledItem.carbGrams,
            fatGrams: scaledItem.fatGrams,
            fiberGrams: scaledItem.fiberGrams
        )
    }
}
