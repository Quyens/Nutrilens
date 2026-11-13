//
//  UserDietaryProfile.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Encapsulates user culinary habits, declared allergens, and taste preferences.
//

import Foundation

public struct UserDietaryProfile: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var preferredCategories: [String]
    public var dislikedIngredients: [String]
    public var declaredAllergens: Set<AllergenType>
    public var dietaryPreferences: Set<DietaryPreferenceType>
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        preferredCategories: [String] = ["Cơm", "Món Nước", "Bún & Mì", "Canh", "Món Mặn"],
        dislikedIngredients: [String] = [],
        declaredAllergens: Set<AllergenType> = [],
        dietaryPreferences: Set<DietaryPreferenceType> = [.vietnamese],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.preferredCategories = preferredCategories
        self.dislikedIngredients = dislikedIngredients
        self.declaredAllergens = declaredAllergens
        self.dietaryPreferences = dietaryPreferences
        self.updatedAt = updatedAt
    }

    /// Checks if a given allergen has been declared by the user
    public func hasDeclaredAllergen(_ allergen: AllergenType) -> Bool {
        declaredAllergens.contains(allergen)
    }

    /// Checks if any candidate ingredient contains a user disliked keyword
    public func dislikes(ingredient: String) -> Bool {
        let normalized = ingredient.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return dislikedIngredients.contains { item in
            let cleanItem = item.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return !cleanItem.isEmpty && normalized.contains(cleanItem)
        }
    }
}

