//
//  RecipeRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol RecipeRepositoryProtocol: Sendable {
    func fetchAllRecipes() async throws -> [Recipe]
    func fetchRecipe(id: UUID) async throws -> Recipe?
    func searchRecipes(query: String) async throws -> [Recipe]
    func saveRecipe(_ recipe: Recipe) async throws
    func updateRecipe(_ recipe: Recipe) async throws
    func deleteRecipe(id: UUID) async throws
    func toggleFavorite(id: UUID) async throws
}

