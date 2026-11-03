//
//  GetMealHistoryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetMealHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> [MealRecord]
    func execute(for date: Date) async throws -> [MealRecord]
    func update(meal: MealRecord) async throws
    func delete(id: UUID) async throws
    func fetchDailySummary(for date: Date) async throws -> NutritionSummary
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

    public func execute(for date: Date) async throws -> [MealRecord] {
        let meals = try await mealRepository.fetchMeals(for: date)
        return meals.sorted(by: { $0.timestamp > $1.timestamp })
    }

    public func update(meal: MealRecord) async throws {
        try await mealRepository.updateMeal(meal)
    }

    public func delete(id: UUID) async throws {
        try await mealRepository.deleteMeal(id: id)
    }

    public func fetchDailySummary(for date: Date) async throws -> NutritionSummary {
        try await mealRepository.fetchDailySummary(for: date)
    }
}
