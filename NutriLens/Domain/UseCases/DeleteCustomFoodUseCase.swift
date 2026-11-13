//
//  DeleteCustomFoodUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol DeleteCustomFoodUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws
}

public final class DeleteCustomFoodUseCase: DeleteCustomFoodUseCaseProtocol, Sendable {
    private let repository: CustomFoodRepositoryProtocol

    public init(repository: CustomFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteCustomFood(id: id)
    }
}

