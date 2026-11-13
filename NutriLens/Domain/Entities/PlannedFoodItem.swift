//
//  PlannedFoodItem.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a single planned food item within a planned meal.
//

import Foundation

public enum PlannedFoodSourceType: String, CaseIterable, Codable, Sendable {
    case vietnameseDatabase = "vietnamese"
    case customFood = "customFood"
    case recipe = "recipe"
    case packagedFood = "packagedFood"
    case manual = "manual"

    public var vietnameseTitle: String {
        switch self {
        case .vietnameseDatabase: return "Món Việt"
        case .customFood: return "Món tự tạo"
        case .recipe: return "Công thức"
        case .packagedFood: return "Đóng gói (Barcode)"
        case .manual: return "Nhập tay"
        }
    }

    public var systemIcon: String {
        switch self {
        case .vietnameseDatabase: return "fork.knife"
        case .customFood: return "person.crop.circle.fill"
        case .recipe: return "book.closed.fill"
        case .packagedFood: return "barcode.viewfinder"
        case .manual: return "square.and.pencil"
        }
    }
}

public struct PlannedNutritionSnapshot: Equatable, Hashable, Codable, Sendable {
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double

    public init(
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double = 0
    ) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }

    public static let zero = PlannedNutritionSnapshot()

    public static func + (lhs: PlannedNutritionSnapshot, rhs: PlannedNutritionSnapshot) -> PlannedNutritionSnapshot {
        PlannedNutritionSnapshot(
            calories: (lhs.calories + rhs.calories).rounded(),
            proteinGrams: ((lhs.proteinGrams + rhs.proteinGrams) * 10).rounded() / 10,
            carbGrams: ((lhs.carbGrams + rhs.carbGrams) * 10).rounded() / 10,
            fatGrams: ((lhs.fatGrams + rhs.fatGrams) * 10).rounded() / 10,
            fiberGrams: ((lhs.fiberGrams + rhs.fiberGrams) * 10).rounded() / 10
        )
    }

    public func scaled(by multiplier: Double) -> PlannedNutritionSnapshot {
        guard multiplier > 0 else { return .zero }
        return PlannedNutritionSnapshot(
            calories: (calories * multiplier).rounded(),
            proteinGrams: ((proteinGrams * multiplier) * 10).rounded() / 10,
            carbGrams: ((carbGrams * multiplier) * 10).rounded() / 10,
            fatGrams: ((fatGrams * multiplier) * 10).rounded() / 10,
            fiberGrams: ((fiberGrams * multiplier) * 10).rounded() / 10
        )
    }
}

public struct PlannedFoodItem: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var sourceType: PlannedFoodSourceType
    public var sourceId: String?
    public var displayName: String
    public var quantity: Double
    public var servingUnit: String
    public var portionMultiplier: Double
    public var nutritionSnapshot: PlannedNutritionSnapshot

    public init(
        id: UUID = UUID(),
        sourceType: PlannedFoodSourceType,
        sourceId: String? = nil,
        displayName: String,
        quantity: Double,
        servingUnit: String = "g",
        portionMultiplier: Double = 1.0,
        nutritionSnapshot: PlannedNutritionSnapshot
    ) {
        self.id = id
        self.sourceType = sourceType
        self.sourceId = sourceId
        self.displayName = displayName
        self.quantity = quantity
        self.servingUnit = servingUnit
        self.portionMultiplier = portionMultiplier
        self.nutritionSnapshot = nutritionSnapshot
    }

    /// Converts this planned food item into a concrete FoodItem for MealRecord when logged to diary
    public func toFoodItem() -> FoodItem {
        FoodItem(
            id: UUID(),
            name: displayName,
            vietnameseName: displayName,
            confidence: 1.0,
            servingSizeGrams: quantity,
            calories: nutritionSnapshot.calories,
            proteinGrams: nutritionSnapshot.proteinGrams,
            carbGrams: nutritionSnapshot.carbGrams,
            fatGrams: nutritionSnapshot.fatGrams,
            fiberGrams: nutritionSnapshot.fiberGrams
        )
    }

    /// Convenience factory from Vietnamese dish
    public static func fromVietnameseDish(_ dish: VietnameseDishProfile, quantityGrams: Double) -> PlannedFoodItem {
        let factor = quantityGrams / max(dish.standardServingGrams, 1.0)
        let snapshot = PlannedNutritionSnapshot(
            calories: (dish.caloriesPerServing * factor).rounded(),
            proteinGrams: ((dish.proteinPerServing * factor) * 10).rounded() / 10,
            carbGrams: ((dish.carbPerServing * factor) * 10).rounded() / 10,
            fatGrams: ((dish.fatPerServing * factor) * 10).rounded() / 10,
            fiberGrams: ((dish.fiberPerServing * factor) * 10).rounded() / 10
        )
        return PlannedFoodItem(
            sourceType: .vietnameseDatabase,
            sourceId: dish.slug,
            displayName: dish.vietnameseName,
            quantity: quantityGrams,
            servingUnit: "g",
            portionMultiplier: factor,
            nutritionSnapshot: snapshot
        )
    }

    /// Convenience factory from CustomFood
    public static func fromCustomFood(_ food: CustomFood, quantityGrams: Double) -> PlannedFoodItem {
        let scaledFood = food.scaled(to: quantityGrams)
        let snapshot = PlannedNutritionSnapshot(
            calories: scaledFood.calories,
            proteinGrams: scaledFood.proteinGrams,
            carbGrams: scaledFood.carbGrams,
            fatGrams: scaledFood.fatGrams,
            fiberGrams: scaledFood.fiberGrams
        )
        return PlannedFoodItem(
            sourceType: .customFood,
            sourceId: food.id.uuidString,
            displayName: food.name,
            quantity: quantityGrams,
            servingUnit: food.servingUnit,
            portionMultiplier: quantityGrams / max(food.servingSizeGrams, 1.0),
            nutritionSnapshot: snapshot
        )
    }

    /// Convenience factory from Recipe
    public static func fromRecipe(_ recipe: Recipe, servings: Double) -> PlannedFoodItem {
        let snap = recipe.scaledNutrition(forServings: servings)
        let totalGrams = recipe.standardServingGrams * servings
        let nutritionSnapshot = PlannedNutritionSnapshot(
            calories: snap.calories,
            proteinGrams: snap.proteinGrams,
            carbGrams: snap.carbGrams,
            fatGrams: snap.fatGrams,
            fiberGrams: snap.fiberGrams
        )
        let unit = servings == 1.0 ? "phần" : "\(servings) phần"
        return PlannedFoodItem(
            sourceType: .recipe,
            sourceId: recipe.id.uuidString,
            displayName: recipe.name,
            quantity: totalGrams,
            servingUnit: unit,
            portionMultiplier: servings,
            nutritionSnapshot: nutritionSnapshot
        )
    }
}

