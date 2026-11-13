//
//  SaveRecipeUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol SaveRecipeUseCaseProtocol: Sendable {
    func execute(_ recipe: Recipe) async throws
    func toggleFavorite(id: UUID) async throws
}

public final class SaveRecipeUseCase: SaveRecipeUseCaseProtocol, Sendable {
    private let repository: RecipeRepositoryProtocol

    public init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ recipe: Recipe) async throws {
        guard !recipe.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidInput("Tên công thức không được để trống.")
        }
        guard recipe.servings >= 1 else {
            throw AppError.invalidInput("Số khẩu phần phải ít nhất là 1.")
        }
        guard !recipe.ingredients.isEmpty else {
            throw AppError.invalidInput("Công thức phải chứa ít nhất 1 nguyên liệu.")
        }

        let existing = try await repository.fetchRecipe(id: recipe.id)
        if existing != nil {
            try await repository.updateRecipe(recipe)
        } else {
            try await repository.saveRecipe(recipe)
        }
    }

    public func toggleFavorite(id: UUID) async throws {
        try await repository.toggleFavorite(id: id)
    }
}

