//
//  MockRecipeRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public final class MockRecipeRepository: RecipeRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var recipes: [Recipe]

    public init(initialRecipes: [Recipe]? = nil) {
        if let initialRecipes {
            self.recipes = initialRecipes
        } else {
            self.recipes = Self.sampleRecipes
        }
    }

    public func fetchAllRecipes() async throws -> [Recipe] {
        lock.lock()
        defer { lock.unlock() }
        return recipes.sorted { (a, b) -> Bool in
            if a.isFavorite != b.isFavorite {
                return a.isFavorite && !b.isFavorite
            }
            return a.createdAt > b.createdAt
        }
    }

    public func fetchRecipe(id: UUID) async throws -> Recipe? {
        lock.lock()
        defer { lock.unlock() }
        return recipes.first { $0.id == id }
    }

    public func searchRecipes(query: String) async throws -> [Recipe] {
        lock.lock()
        defer { lock.unlock() }
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        guard !clean.isEmpty else { return recipes }

        return recipes.filter { recipe in
            let nameFolded = recipe.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let ingredientMatch = recipe.ingredients.contains { ing in
                ing.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(clean)
            }
            return nameFolded.contains(clean) || ingredientMatch
        }
    }

    public func saveRecipe(_ recipe: Recipe) async throws {
        lock.lock()
        defer { lock.unlock() }
        recipes.removeAll { $0.id == recipe.id }
        recipes.insert(recipe, at: 0)
    }

    public func updateRecipe(_ recipe: Recipe) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.insert(recipe, at: 0)
        }
    }

    public func deleteRecipe(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        recipes.removeAll { $0.id == id }
    }

    public func toggleFavorite(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let index = recipes.firstIndex(where: { $0.id == id }) {
            var item = recipes[index]
            item.isFavorite.toggle()
            item.updatedAt = Date()
            recipes[index] = item
        }
    }

    // MARK: - Sample Recipes for SwiftUI Previews & Tests
    public static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "Bún Thịt Nướng Sốt Tỏi Ớt Healthy",
            servings: 2,
            prepTimeMinutes: 20,
            cookingTimeMinutes: 15,
            ingredients: [
                RecipeIngredient(
                    name: "Bún tươi",
                    sourceType: .manual,
                    amountGrams: 300,
                    calories: 330,
                    proteinGrams: 5.0,
                    carbGrams: 75.0,
                    fatGrams: 0.6,
                    fiberGrams: 1.2
                ),
                RecipeIngredient(
                    name: "Thịt nạc heo ướp nướng",
                    sourceType: .manual,
                    amountGrams: 200,
                    calories: 320,
                    proteinGrams: 42.0,
                    carbGrams: 4.0,
                    fatGrams: 14.0,
                    fiberGrams: 0.5
                ),
                RecipeIngredient(
                    name: "Rau thơm, giá đỗ, dưa leo",
                    sourceType: .manual,
                    amountGrams: 150,
                    calories: 35,
                    proteinGrams: 2.5,
                    carbGrams: 6.0,
                    fatGrams: 0.3,
                    fiberGrams: 2.8
                ),
                RecipeIngredient(
                    name: "Nước mắm chua ngọt ít đường",
                    sourceType: .manual,
                    amountGrams: 50,
                    calories: 45,
                    proteinGrams: 1.5,
                    carbGrams: 9.0,
                    fatGrams: 0.1,
                    fiberGrams: 0.2
                )
            ],
            instructions: [
                "Ướp thịt nạc với tỏi, sả băm, mật ong và tiêu trong 15 phút.",
                "Nướng thịt trong nồi chiên không dầu ở 180°C trong 12 phút.",
                "Trần sơ bún tươi qua nước sôi, xếp vào tô cùng rau sống và giá đỗ.",
                "Đặt thịt nướng lên trên, chan nước mắm chua ngọt và thưởng thức."
            ],
            notes: "Công thức chuẩn dinh dưỡng ít chất béo bão hòa.",
            isFavorite: true
        ),
        Recipe(
            name: "Salad Ức Gà Sốt Mè Rang Bơ Đậu Phộng",
            servings: 1,
            prepTimeMinutes: 15,
            cookingTimeMinutes: 10,
            ingredients: [
                RecipeIngredient(
                    name: "Ức gà áp chảo",
                    sourceType: .manual,
                    amountGrams: 150,
                    calories: 220,
                    proteinGrams: 36.0,
                    carbGrams: 1.5,
                    fatGrams: 7.0,
                    fiberGrams: 0.5
                ),
                RecipeIngredient(
                    name: "Xà lách Romaine & cà chua bi",
                    sourceType: .manual,
                    amountGrams: 150,
                    calories: 40,
                    proteinGrams: 2.0,
                    carbGrams: 7.0,
                    fatGrams: 0.4,
                    fiberGrams: 2.5
                ),
                RecipeIngredient(
                    name: "Sốt mè rang đậu phộng",
                    sourceType: .manual,
                    amountGrams: 30,
                    calories: 120,
                    proteinGrams: 3.5,
                    carbGrams: 5.0,
                    fatGrams: 10.0,
                    fiberGrams: 1.0
                )
            ],
            instructions: [
                "Áp chảo ức gà chín vàng hai mặt với dầu oliu xịt.",
                "Rửa sạch rau củ, cà chua bi cắt đôi xếp vào đĩa.",
                "Cắt lát ức gà bày lên rau, rưới sốt mè rang."
            ],
            notes: "Bữa trưa giàu đạm lý tưởng sau tập luyện.",
            isFavorite: false
        )
    ]
}

