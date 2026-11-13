//
//  DeleteRecipeUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol DeleteRecipeUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws
}

public final class DeleteRecipeUseCase: DeleteRecipeUseCaseProtocol, Sendable {
    private let repository: RecipeRepositoryProtocol

    public init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteRecipe(id: id)
    }
}

