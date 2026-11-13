//
//  GetWeeklyMealPlanUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetWeeklyMealPlanUseCaseProtocol: Sendable {
    func execute(forWeekContaining date: Date) async throws -> WeeklyMealPlan
}

public final class GetWeeklyMealPlanUseCase: GetWeeklyMealPlanUseCaseProtocol {
    private let repository: MealPlanRepositoryProtocol

    public init(repository: MealPlanRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(forWeekContaining date: Date) async throws -> WeeklyMealPlan {
        try await repository.getWeeklyPlan(forWeekContaining: date)
    }
}

