//
//  MockFoodFavoritesRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  In-memory mock for food favorites and recently viewed history testing.
//

import Foundation

public final class MockFoodFavoritesRepository: FoodFavoritesRepositoryProtocol, @unchecked Sendable {
    private var favoriteIds: Set<String>
    private var recentlyViewedIds: [String]
    private let lock = NSLock()

    public init(
        favoriteIds: Set<String> = [],
        recentlyViewedIds: [String] = []
    ) {
        self.favoriteIds = favoriteIds
        self.recentlyViewedIds = recentlyViewedIds
    }

    public func getFavoriteIds() -> Set<String> {
        lock.lock()
        defer { lock.unlock() }
        return favoriteIds
    }

    public func toggleFavorite(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
            return false
        } else {
            favoriteIds.insert(id)
            return true
        }
    }

    public func isFavorite(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return favoriteIds.contains(id)
    }

    public func getRecentlyViewedIds() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return recentlyViewedIds
    }

    public func recordRecentlyViewed(id: String) {
        lock.lock()
        defer { lock.unlock() }
        recentlyViewedIds.removeAll { $0 == id }
        recentlyViewedIds.insert(id, at: 0)
        if recentlyViewedIds.count > 12 {
            recentlyViewedIds = Array(recentlyViewedIds.prefix(12))
        }
    }

    public func clearRecentlyViewed() {
        lock.lock()
        defer { lock.unlock() }
        recentlyViewedIds.removeAll()
    }
}
