//
//  GetRecipesUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetRecipesUseCaseProtocol: Sendable {
    func execute() async throws -> [Recipe]
    func execute(query: String) async throws -> [Recipe]
    func execute(id: UUID) async throws -> Recipe?
}

public final class GetRecipesUseCase: GetRecipesUseCaseProtocol, Sendable {
    private let repository: RecipeRepositoryProtocol

    public init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Recipe] {
        try await repository.fetchAllRecipes()
    }

    public func execute(query: String) async throws -> [Recipe] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return try await repository.fetchAllRecipes()
        }
        return try await repository.searchRecipes(query: query)
    }

    public func execute(id: UUID) async throws -> Recipe? {
        try await repository.fetchRecipe(id: id)
    }
}

