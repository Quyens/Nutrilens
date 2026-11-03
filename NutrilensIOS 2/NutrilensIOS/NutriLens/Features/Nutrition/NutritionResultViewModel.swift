//
//  NutritionResultViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class NutritionResultViewModel: ObservableObject {
    @Published public private(set) var foodItem: FoodItem
    @Published public var servingSizeGrams: Double {
        didSet {
            scaledItem = foodItem.scaled(to: servingSizeGrams)
        }
    }
    @Published public private(set) var scaledItem: FoodItem

    public init(foodItem: FoodItem) {
        self.foodItem = foodItem
        self.servingSizeGrams = foodItem.servingSizeGrams
        self.scaledItem = foodItem
    }

    public func adjustGrams(by delta: Double) {
        let updated = max(50, servingSizeGrams + delta)
        servingSizeGrams = updated
    }

    public func setGrams(_ grams: Double) {
        servingSizeGrams = max(50, grams)
    }

    public func updateName(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        foodItem = FoodItem(
            id: foodItem.id,
            name: foodItem.name,
            vietnameseName: trimmed,
            confidence: foodItem.confidence,
            servingSizeGrams: foodItem.servingSizeGrams,
            calories: foodItem.calories,
            proteinGrams: foodItem.proteinGrams,
            carbGrams: foodItem.carbGrams,
            fatGrams: foodItem.fatGrams,
            fiberGrams: foodItem.fiberGrams
        )
        scaledItem = foodItem.scaled(to: servingSizeGrams)
    }
}
