//
//  FoodFavoritesRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Persistent UserDefaults storage for favorite food items and recently viewed history.
//

import Foundation

public final class FoodFavoritesRepository: FoodFavoritesRepositoryProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let favoritesKey = "nutrilens.favorites.dish_ids"
    private let recentsKey = "nutrilens.recently_viewed.dish_ids"
    private let lock = NSLock()
    private let maxRecents = 12

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Favorites

    public func getFavoriteIds() -> Set<String> {
        lock.lock()
        defer { lock.unlock() }
        let array = userDefaults.stringArray(forKey: favoritesKey) ?? []
        return Set(array)
    }

    @discardableResult
    public func toggleFavorite(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        var current = Set(userDefaults.stringArray(forKey: favoritesKey) ?? [])
        let isNowFavorited: Bool
        if current.contains(id) {
            current.remove(id)
            isNowFavorited = false
        } else {
            current.insert(id)
            isNowFavorited = true
        }
        userDefaults.set(Array(current), forKey: favoritesKey)
        return isNowFavorited
    }

    public func isFavorite(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let set = Set(userDefaults.stringArray(forKey: favoritesKey) ?? [])
        return set.contains(id)
    }

    // MARK: - Recently Viewed

    public func getRecentlyViewedIds() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return userDefaults.stringArray(forKey: recentsKey) ?? []
    }

    public func recordRecentlyViewed(id: String) {
        lock.lock()
        defer { lock.unlock() }
        var list = userDefaults.stringArray(forKey: recentsKey) ?? []
        list.removeAll { $0 == id }
        list.insert(id, at: 0)
        if list.count > maxRecents {
            list = Array(list.prefix(maxRecents))
        }
        userDefaults.set(list, forKey: recentsKey)
    }

    public func clearRecentlyViewed() {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.removeObject(forKey: recentsKey)
    }
}
