//
//  SmartSuggestionsFilter.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Filter criteria applied to smart meal recommendations.
//

import Foundation

public struct SmartSuggestionsFilter: Equatable, Sendable {
    public var mealCategory: PlannedMealCategory?
    public var foodCategory: String?
    public var favoriteOnly: Bool
    public var activeDietaryStyle: DietaryPreferenceType?
    public var excludeKnownAllergens: Bool
    public var searchQuery: String

    public init(
        mealCategory: PlannedMealCategory? = nil,
        foodCategory: String? = nil,
        favoriteOnly: Bool = false,
        activeDietaryStyle: DietaryPreferenceType? = nil,
        excludeKnownAllergens: Bool = true,
        searchQuery: String = ""
    ) {
        self.mealCategory = mealCategory
        self.foodCategory = foodCategory
        self.favoriteOnly = favoriteOnly
        self.activeDietaryStyle = activeDietaryStyle
        self.excludeKnownAllergens = excludeKnownAllergens
        self.searchQuery = searchQuery
    }

    public static let `default` = SmartSuggestionsFilter()
}

