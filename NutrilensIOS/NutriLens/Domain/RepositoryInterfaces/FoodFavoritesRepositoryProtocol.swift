//
//  FoodFavoritesRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Protocol defining persistent storage for user favorites and recently viewed food dishes.
//

import Foundation

public protocol FoodFavoritesRepositoryProtocol: Sendable {
    func getFavoriteIds() -> Set<String>
    func toggleFavorite(id: String) -> Bool
    func isFavorite(id: String) -> Bool

    func getRecentlyViewedIds() -> [String]
    func recordRecentlyViewed(id: String)
    func clearRecentlyViewed()
}
