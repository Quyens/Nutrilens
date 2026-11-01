//
//  GetMealHistoryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetMealHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> [MealRecord]
    func delete(id: UUID) async throws
}

public final class GetMealHistoryUseCase: GetMealHistoryUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol

    public init(mealRepository: MealRepositoryProtocol) {
        self.mealRepository = mealRepository
    }

    public func execute() async throws -> [MealRecord] {
        let meals = try await mealRepository.fetchAllMeals()
        return meals.sorted(by: { $0.timestamp > $1.timestamp })
    }

    public func delete(id: UUID) async throws {
        try await mealRepository.deleteMeal(id: id)
    }
}
