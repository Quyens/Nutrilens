//
//  PackagedFood.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a packaged retail consumer food product identified by barcode.
//

import Foundation

public struct PackagedFood: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var barcode: String // Normalized GS1/GTIN-13
    public var rawBarcode: String
    public var barcodeType: BarcodeType
    public var productName: String
    public var brand: String?
    public var category: String
    public var serving: PackagedFoodServing
    public var nutrition: PackagedFoodNutrition
    public var ingredients: [String]
    public var ingredientText: String?
    public var allergens: [AllergenType]
    public var verificationStatus: IngredientVerificationStatus
    public var isFavorite: Bool
    public var lastScannedAt: Date?
    public let createdAt: Date
    public var updatedAt: Date
    public var notes: String?
    public var imagePath: String?

    public init(
        id: UUID = UUID(),
        barcode: String,
        rawBarcode: String? = nil,
        barcodeType: BarcodeType = .ean13,
        productName: String,
        brand: String? = nil,
        category: String = "Thực phẩm đóng gói",
        serving: PackagedFoodServing = PackagedFoodServing(),
        nutrition: PackagedFoodNutrition = PackagedFoodNutrition(),
        ingredients: [String] = [],
        ingredientText: String? = nil,
        allergens: [AllergenType] = [],
        verificationStatus: IngredientVerificationStatus = .partial,
        isFavorite: Bool = false,
        lastScannedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.barcode = barcode
        self.rawBarcode = rawBarcode ?? barcode
        self.barcodeType = barcodeType
        self.productName = productName
        self.brand = brand
        self.category = category
        self.serving = serving
        self.nutrition = nutrition
        self.ingredients = ingredients
        self.ingredientText = ingredientText
        self.allergens = allergens
        self.verificationStatus = verificationStatus
        self.isFavorite = isFavorite
        self.lastScannedAt = lastScannedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.imagePath = imagePath
    }

    /// Full display title including brand if present
    public var fullDisplayTitle: String {
        if let brand, !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(brand) - \(productName)"
        }
        return productName
    }

    /// Converts this packaged food into an immutable FoodItem snapshot for Meal Diary logging
    public func toFoodItem(portionMultiplier: Double = 1.0) -> FoodItem {
        let scaledNutr = nutrition.scaled(by: portionMultiplier)
        let totalGrams = serving.servingGramsEquivalent * max(0.01, portionMultiplier)

        return FoodItem(
            name: fullDisplayTitle,
            vietnameseName: fullDisplayTitle,
            confidence: 1.0, // Scanned barcode has exact barcode identity
            servingSizeGrams: totalGrams,
            calories: scaledNutr.calories,
            proteinGrams: scaledNutr.proteinGrams,
            carbGrams: scaledNutr.carbGrams,
            fatGrams: scaledNutr.fatGrams,
            fiberGrams: scaledNutr.fiberGrams ?? 0
        )
    }

    /// Converts into a PlannedFoodItem for Weekly Meal Planner
    public func toPlannedFoodItem(portionMultiplier: Double = 1.0) -> PlannedFoodItem {
        let scaledNutr = nutrition.scaled(by: portionMultiplier)
        let totalGrams = serving.servingGramsEquivalent * max(0.01, portionMultiplier)

        let snapshot = PlannedNutritionSnapshot(
            calories: scaledNutr.calories,
            proteinGrams: scaledNutr.proteinGrams,
            carbGrams: scaledNutr.carbGrams,
            fatGrams: scaledNutr.fatGrams,
            fiberGrams: scaledNutr.fiberGrams ?? 0
        )

        return PlannedFoodItem(
            sourceType: .packagedFood,
            sourceId: barcode,
            displayName: fullDisplayTitle,
            quantity: totalGrams,
            servingUnit: serving.servingUnit,
            portionMultiplier: portionMultiplier,
            nutritionSnapshot: snapshot
        )
    }
}

