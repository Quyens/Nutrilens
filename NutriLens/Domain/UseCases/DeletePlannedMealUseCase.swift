//
//  DeletePlannedMealUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol DeletePlannedMealUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws
}

public final class DeletePlannedMealUseCase: DeletePlannedMealUseCaseProtocol {
    private let repository: MealPlanRepositoryProtocol

    public init(repository: MealPlanRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deletePlannedMeal(id: id)
    }
}

