//
//  FoodItem.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Note: Domain layer contains purely business entities independent of SwiftUI / UI frameworks.
//

import Foundation

public struct FoodItem: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let vietnameseName: String
    public let confidence: Double
    public let servingSizeGrams: Double
    public let calories: Double
    public let proteinGrams: Double
    public let carbGrams: Double
    public let fatGrams: Double
    public let fiberGrams: Double

    public init(
        id: UUID = UUID(),
        name: String,
        vietnameseName: String,
        confidence: Double,
        servingSizeGrams: Double,
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double
    ) {
        self.id = id
        self.name = name
        self.vietnameseName = vietnameseName
        self.confidence = confidence
        self.servingSizeGrams = servingSizeGrams
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }

    /// Calculates scaled nutrition based on target serving size in grams
    public func scaled(to targetGrams: Double) -> FoodItem {
        guard servingSizeGrams > 0 else { return self }
        let factor = targetGrams / servingSizeGrams
        return FoodItem(
            id: id,
            name: name,
            vietnameseName: vietnameseName,
            confidence: confidence,
            servingSizeGrams: targetGrams,
            calories: (calories * factor).rounded(),
            proteinGrams: (proteinGrams * factor * 10).rounded() / 10,
            carbGrams: (carbGrams * factor * 10).rounded() / 10,
            fatGrams: (fatGrams * factor * 10).rounded() / 10,
            fiberGrams: (fiberGrams * factor * 10).rounded() / 10
        )
    }
}
