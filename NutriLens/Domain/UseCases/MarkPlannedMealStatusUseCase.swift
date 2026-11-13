//
//  MarkPlannedMealStatusUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol MarkPlannedMealStatusUseCaseProtocol: Sendable {
    func markCompleted(mealId: UUID, linkedDiaryRecordId: UUID) async throws
    func markSkipped(mealId: UUID) async throws
    func restorePlanned(mealId: UUID) async throws
}

public final class MarkPlannedMealStatusUseCase: MarkPlannedMealStatusUseCaseProtocol {
    private let repository: MealPlanRepositoryProtocol

    public init(repository: MealPlanRepositoryProtocol) {
        self.repository = repository
    }

    public func markCompleted(mealId: UUID, linkedDiaryRecordId: UUID) async throws {
        try await repository.markMealCompleted(id: mealId, linkedDiaryRecordId: linkedDiaryRecordId)
    }

    public func markSkipped(mealId: UUID) async throws {
        try await repository.markMealSkipped(id: mealId)
    }

    public func restorePlanned(mealId: UUID) async throws {
        try await repository.restorePlannedStatus(id: mealId)
    }
}

