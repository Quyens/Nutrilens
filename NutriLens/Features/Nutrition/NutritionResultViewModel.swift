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
}
