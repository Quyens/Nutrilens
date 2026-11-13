//
//  SavePlannedMealUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol SavePlannedMealUseCaseProtocol: Sendable {
    func execute(_ meal: PlannedMeal) async throws
}

public final class SavePlannedMealUseCase: SavePlannedMealUseCaseProtocol {
    private let repository: MealPlanRepositoryProtocol

    public init(repository: MealPlanRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ meal: PlannedMeal) async throws {
        guard !meal.foodItems.isEmpty else {
            throw AppError.invalidInput("Kế hoạch bữa ăn phải có ít nhất một món ăn.")
        }
        for item in meal.foodItems {
            guard item.quantity > 0 else {
                throw AppError.invalidInput("Khẩu phần của món \(item.displayName) phải lớn hơn 0.")
            }
        }
        try await repository.savePlannedMeal(meal)
    }
}

