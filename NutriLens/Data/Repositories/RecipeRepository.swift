//
//  RecipeRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  SwiftData implementation of RecipeRepositoryProtocol.
//

import Foundation
import SwiftData

public final class RecipeRepository: RecipeRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    @MainActor
    public func fetchAllRecipes() async throws -> [Recipe] {
        let descriptor = FetchDescriptor<RecipeSDModel>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        do {
            var results: [RecipeSDModel] = try container.mainContext.fetch(descriptor)
            if results.isEmpty && !UserDefaults.standard.bool(forKey: "recipes_seeded_or_cleared") {
                UserDefaults.standard.set(true, forKey: "recipes_seeded_or_cleared")
                for sample in MockRecipeRepository.sampleRecipes {
                    let model = RecipeSDModel(from: sample)
                    container.mainContext.insert(model)
                }
                try? container.mainContext.save()
                results = (try? container.mainContext.fetch(descriptor)) ?? []
            }
            return results.map { $0.toDomain() }.sorted { (a, b) -> Bool in
                if a.isFavorite != b.isFavorite {
                    return a.isFavorite && !b.isFavorite
                }
                return a.createdAt > b.createdAt
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch recipes: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchRecipe(id: UUID) async throws -> Recipe? {
        let descriptor = FetchDescriptor<RecipeSDModel>(
            predicate: #Predicate<RecipeSDModel> { $0.id == id }
        )
        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.first?.toDomain()
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch recipe: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func searchRecipes(query: String) async throws -> [Recipe] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        let all = try await fetchAllRecipes()
        guard !clean.isEmpty else { return all }

        return all.filter { recipe in
            let nameFolded = recipe.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let notesFolded = recipe.notes?.folding(options: .diacriticInsensitive, locale: .current).lowercased() ?? ""
            let ingredientMatch = recipe.ingredients.contains { ing in
                ing.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(clean)
            }
            return nameFolded.contains(clean) || notesFolded.contains(clean) || ingredientMatch
        }
    }

    @MainActor
    public func saveRecipe(_ recipe: Recipe) async throws {
        let context = container.mainContext
        let model = RecipeSDModel(from: recipe)
        context.insert(model)
        do {
            try context.save()
            AppLogger.data.info("Saved recipe: \(recipe.name)")
        } catch {
            throw AppError.dataPersistenceFailed("Failed to save recipe: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func updateRecipe(_ recipe: Recipe) async throws {
        let context = container.mainContext
        let targetId = recipe.id
        let descriptor = FetchDescriptor<RecipeSDModel>(
            predicate: #Predicate<RecipeSDModel> { $0.id == targetId }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.name = recipe.name
                existing.servings = recipe.servings
                existing.prepTimeMinutes = recipe.prepTimeMinutes
                existing.cookingTimeMinutes = recipe.cookingTimeMinutes
                existing.notes = recipe.notes
                existing.isFavorite = recipe.isFavorite
                existing.imagePath = recipe.imagePath
                existing.instructionsRaw = recipe.instructions.isEmpty ? nil : recipe.instructions.joined(separator: "\n---STEP---\n")

                // Update ingredients relationship
                existing.ingredients.forEach { context.delete($0) }
                existing.ingredients = recipe.ingredients.map { RecipeIngredientSDModel(from: $0) }

                existing.updatedAt = Date()
                try context.save()
                AppLogger.data.info("Updated recipe: \(recipe.name)")
            } else {
                try await saveRecipe(recipe)
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to update recipe: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func deleteRecipe(id: UUID) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<RecipeSDModel>(
            predicate: #Predicate<RecipeSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
                AppLogger.data.info("Deleted recipe ID: \(id)")
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to delete recipe: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func toggleFavorite(id: UUID) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<RecipeSDModel>(
            predicate: #Predicate<RecipeSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.isFavorite.toggle()
                existing.updatedAt = Date()
                try context.save()
                AppLogger.data.info("Toggled favorite for recipe ID: \(id)")
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to toggle favorite for recipe: \(error.localizedDescription)")
        }
    }
}
