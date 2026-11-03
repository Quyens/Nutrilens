//
//  LogMealViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class LogMealViewModel: ObservableObject {
    @Published public var mealType: MealType = .lunch
    @Published public var foodName: String = ""
    @Published public var caloriesText: String = ""
    @Published public var proteinText: String = ""
    @Published public var carbsText: String = ""
    @Published public var fatText: String = ""
    @Published public var notes: String = ""
    @Published public private(set) var isSaving: Bool = false
    @Published public var errorMessage: String?

    private let logMealUseCase: LogMealUseCaseProtocol
    private let onDismiss: () -> Void

    public init(
        logMealUseCase: LogMealUseCaseProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.logMealUseCase = logMealUseCase
        self.onDismiss = onDismiss
    }

    public func saveMeal() {
        guard !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter food name."
            return
        }

        let calories = Double(caloriesText) ?? 0
        let protein = Double(proteinText) ?? 0
        let carbs = Double(carbsText) ?? 0
        let fat = Double(fatText) ?? 0

        let item = FoodItem(
            name: foodName,
            vietnameseName: foodName,
            confidence: 1.0,
            servingSizeGrams: 200,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat,
            fiberGrams: 0
        )

        let record = MealRecord(
            mealType: mealType,
            items: [item],
            notes: notes.isEmpty ? nil : notes
        )

        Task {
            isSaving = true
            do {
                try await logMealUseCase.execute(meal: record)
                isSaving = false
                onDismiss()
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
