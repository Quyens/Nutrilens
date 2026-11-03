//
//  NutritionSummary.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public struct NutritionSummary: Equatable, Sendable {
    public let date: Date
    public let consumedCalories: Double
    public let targetCalories: Double
    public let consumedProteinGrams: Double
    public let targetProteinGrams: Double
    public let consumedCarbGrams: Double
    public let targetCarbGrams: Double
    public let consumedFatGrams: Double
    public let targetFatGrams: Double
    public let consumedFiberGrams: Double
    public let targetFiberGrams: Double

    public init(
        date: Date = Date(),
        consumedCalories: Double = 0,
        targetCalories: Double = 2000,
        consumedProteinGrams: Double = 0,
        targetProteinGrams: Double = 130,
        consumedCarbGrams: Double = 0,
        targetCarbGrams: Double = 220,
        consumedFatGrams: Double = 0,
        targetFatGrams: Double = 65,
        consumedFiberGrams: Double = 0,
        targetFiberGrams: Double = 30
    ) {
        self.date = date
        self.consumedCalories = consumedCalories
        self.targetCalories = targetCalories
        self.consumedProteinGrams = consumedProteinGrams
        self.targetProteinGrams = targetProteinGrams
        self.consumedCarbGrams = consumedCarbGrams
        self.targetCarbGrams = targetCarbGrams
        self.consumedFatGrams = consumedFatGrams
        self.targetFatGrams = targetFatGrams
        self.consumedFiberGrams = consumedFiberGrams
        self.targetFiberGrams = targetFiberGrams
    }

    public var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(max(consumedCalories / targetCalories, 0), 1.5)
    }

    public var remainingCalories: Double {
        max(targetCalories - consumedCalories, 0)
    }
}
