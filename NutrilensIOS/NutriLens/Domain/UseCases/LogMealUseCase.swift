//
//  LogMealUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol LogMealUseCaseProtocol: Sendable {
    func execute(meal: MealRecord) async throws
}

public final class LogMealUseCase: LogMealUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol

    public init(mealRepository: MealRepositoryProtocol) {
        self.mealRepository = mealRepository
    }

    public func execute(meal: MealRecord) async throws {
        guard !meal.items.isEmpty else {
            throw AppError.invalidInput("A meal record must contain at least one food item.")
        }
        try await mealRepository.saveMeal(meal)
    }
}
