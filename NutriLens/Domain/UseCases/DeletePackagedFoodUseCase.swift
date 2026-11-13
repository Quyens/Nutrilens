//
//  DeletePackagedFoodUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Deletes a packaged food item from user SwiftData storage.
//

import Foundation

public final class DeletePackagedFoodUseCase: Sendable {
    private let repository: PackagedFoodRepositoryProtocol

    public init(repository: PackagedFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}

