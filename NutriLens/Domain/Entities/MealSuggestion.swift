//
//  MealSuggestion.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents an explainable, personalized meal recommendation.
//

import Foundation

public struct SuggestionExplanationFactor: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let systemIcon: String
    public let scoreImpact: Int // Positive points contributed

    public init(id: String = UUID().uuidString, title: String, detail: String, systemIcon: String, scoreImpact: Int) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemIcon = systemIcon
        self.scoreImpact = scoreImpact
    }
}

public struct MealSuggestion: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let foodSource: PlannedFoodSourceType
    public let sourceId: String?
    public let displayName: String
    public let dishCategory: String
    public let suggestedServing: String
    public let suggestedServingGrams: Double
    public let availableNutritionEstimate: PlannedNutritionSnapshot
    public let recommendationScore: Int // 0 - 100, deterministic rule-based
    public let explanationReasons: [String]
    public let explanationFactors: [SuggestionExplanationFactor]
    public let ingredientVerificationStatus: IngredientVerificationStatus
    public let documentedIngredients: [String]
    public let allergenWarnings: [AllergenType]
    public let hasAllergenConflict: Bool
    public var isFavorite: Bool
    public let imageName: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        foodSource: PlannedFoodSourceType,
        sourceId: String?,
        displayName: String,
        dishCategory: String,
        suggestedServing: String,
        suggestedServingGrams: Double,
        availableNutritionEstimate: PlannedNutritionSnapshot,
        recommendationScore: Int,
        explanationReasons: [String],
        explanationFactors: [SuggestionExplanationFactor] = [],
        ingredientVerificationStatus: IngredientVerificationStatus,
        documentedIngredients: [String] = [],
        allergenWarnings: [AllergenType] = [],
        hasAllergenConflict: Bool = false,
        isFavorite: Bool = false,
        imageName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.foodSource = foodSource
        self.sourceId = sourceId
        self.displayName = displayName
        self.dishCategory = dishCategory
        self.suggestedServing = suggestedServing
        self.suggestedServingGrams = suggestedServingGrams
        self.availableNutritionEstimate = availableNutritionEstimate
        self.recommendationScore = max(0, min(100, recommendationScore))
        self.explanationReasons = explanationReasons
        self.explanationFactors = explanationFactors
        self.ingredientVerificationStatus = ingredientVerificationStatus
        self.documentedIngredients = documentedIngredients
        self.allergenWarnings = allergenWarnings
        self.hasAllergenConflict = hasAllergenConflict
        self.isFavorite = isFavorite
        self.imageName = imageName
        self.createdAt = createdAt
    }

    /// Human-readable match rating (Avoids misleading pseudo-scientific probability percentages)
    public var scoreDescription: String {
        switch recommendationScore {
        case 85...100:
            return "Rất phù hợp"
        case 70...84:
            return "Phù hợp tốt"
        case 50...69:
            return "Phù hợp"
        default:
            return "Gợi ý tham khảo"
        }
    }
}

