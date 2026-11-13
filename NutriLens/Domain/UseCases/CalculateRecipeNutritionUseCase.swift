//
//  CalculateRecipeNutritionUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public struct CalculatedRecipeSummary: Equatable, Sendable {
    public let totalCalories: Double
    public let totalProteinGrams: Double
    public let totalCarbGrams: Double
    public let totalFatGrams: Double
    public let totalFiberGrams: Double
    public let totalWeightGrams: Double

    public let perServingCalories: Double
    public let perServingProteinGrams: Double
    public let perServingCarbGrams: Double
    public let perServingFatGrams: Double
    public let perServingFiberGrams: Double
    public let perServingWeightGrams: Double

    public let servings: Int
}

public protocol CalculateRecipeNutritionUseCaseProtocol: Sendable {
    func execute(ingredients: [RecipeIngredient], servings: Int) -> CalculatedRecipeSummary
}

public final class CalculateRecipeNutritionUseCase: CalculateRecipeNutritionUseCaseProtocol, Sendable {
    public init() {}

    public func execute(ingredients: [RecipeIngredient], servings: Int) -> CalculatedRecipeSummary {
        let safeServings = max(servings, 1)

        let totalCal = ingredients.reduce(0.0) { $0 + $1.calories }
        let totalPro = ingredients.reduce(0.0) { $0 + $1.proteinGrams }
        let totalCarb = ingredients.reduce(0.0) { $0 + $1.carbGrams }
        let totalFat = ingredients.reduce(0.0) { $0 + $1.fatGrams }
        let totalFiber = ingredients.reduce(0.0) { $0 + $1.fiberGrams }
        let totalWeight = ingredients.reduce(0.0) { $0 + $1.amountGrams }

        let perCal = (totalCal / Double(safeServings)).rounded()
        let perPro = ((totalPro / Double(safeServings) * 10).rounded()) / 10
        let perCarb = ((totalCarb / Double(safeServings) * 10).rounded()) / 10
        let perFat = ((totalFat / Double(safeServings) * 10).rounded()) / 10
        let perFiber = ((totalFiber / Double(safeServings) * 10).rounded()) / 10
        let perWeight = (totalWeight / Double(safeServings)).rounded()

        return CalculatedRecipeSummary(
            totalCalories: totalCal.rounded(),
            totalProteinGrams: ((totalPro * 10).rounded()) / 10,
            totalCarbGrams: ((totalCarb * 10).rounded()) / 10,
            totalFatGrams: ((totalFat * 10).rounded()) / 10,
            totalFiberGrams: ((totalFiber * 10).rounded()) / 10,
            totalWeightGrams: totalWeight.rounded(),
            perServingCalories: perCal,
            perServingProteinGrams: perPro,
            perServingCarbGrams: perCarb,
            perServingFatGrams: perFat,
            perServingFiberGrams: perFiber,
            perServingWeightGrams: perWeight,
            servings: safeServings
        )
    }
}

