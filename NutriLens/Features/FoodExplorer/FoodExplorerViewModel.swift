//
//  FoodExplorerViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation ViewModel for the Vietnamese Food Database & Explorer V1.
//

import SwiftUI
import Combine

@MainActor
public final class FoodExplorerViewModel: ObservableObject {
    private let favoritesRepository: FoodFavoritesRepositoryProtocol
    private let allDishes: [VietnameseDishProfile]

    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: FoodExplorerCategory = .all
    @Published public var onlyFavorites: Bool = false
    @Published public var favoriteIds: Set<String> = []
    @Published public var recentlyViewedDishes: [VietnameseDishProfile] = []
    @Published public var selectedDishForDetail: VietnameseDishProfile? = nil

    public init(
        favoritesRepository: FoodFavoritesRepositoryProtocol,
        dishes: [VietnameseDishProfile] = VietnameseNutritionDatabase.dishes
    ) {
        self.favoritesRepository = favoritesRepository
        self.allDishes = dishes
        loadData()
    }

    public func loadData() {
        self.favoriteIds = favoritesRepository.getFavoriteIds()
        refreshRecentlyViewed()
    }

    public func refreshRecentlyViewed() {
        let recentIds = favoritesRepository.getRecentlyViewedIds()
        var results: [VietnameseDishProfile] = []
        for id in recentIds {
            if let dish = allDishes.first(where: { $0.id == id }) {
                results.append(dish)
            }
        }
        self.recentlyViewedDishes = results
    }

    public var totalCount: Int {
        allDishes.count
    }

    public var favoritesCount: Int {
        favoriteIds.count
    }

    public var featuredDishes: [VietnameseDishProfile] {
        let signatureIds = ["dish_pho", "dish_banh_mi", "dish_bun_cha", "dish_com_tam", "dish_goi_cuon"]
        let matching = signatureIds.compactMap { id in allDishes.first(where: { $0.id == id }) }
        if matching.isEmpty {
            return Array(allDishes.prefix(5))
        }
        return matching
    }

    public var filteredDishes: [VietnameseDishProfile] {
        var list = allDishes

        if onlyFavorites {
            list = list.filter { favoriteIds.contains($0.id) }
        }

        if selectedCategory != .all {
            list = list.filter { selectedCategory.matches(profile: $0) }
        }

        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanQuery.isEmpty {
            let foldedQuery = cleanQuery.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            list = list.filter { dish in
                let foldedVN = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
                let foldedEN = dish.englishName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
                let foldedCat = dish.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
                let foldedSlug = dish.slug.lowercased()
                let foldedId = dish.id.lowercased()
                let matchKeyword = dish.keywords.contains { kw in
                    kw.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(foldedQuery)
                }

                return foldedVN.contains(foldedQuery) ||
                       foldedEN.contains(foldedQuery) ||
                       foldedCat.contains(foldedQuery) ||
                       foldedSlug.contains(foldedQuery) ||
                       foldedId.contains(foldedQuery) ||
                       matchKeyword
            }
        }

        return list
    }

    public func isFavorite(dishId: String) -> Bool {
        favoriteIds.contains(dishId)
    }

    public func toggleFavorite(dishId: String) {
        let isNowFav = favoritesRepository.toggleFavorite(id: dishId)
        if isNowFav {
            favoriteIds.insert(dishId)
        } else {
            favoriteIds.remove(dishId)
        }
    }

    public func openDishDetail(dish: VietnameseDishProfile) {
        favoritesRepository.recordRecentlyViewed(id: dish.id)
        refreshRecentlyViewed()
        selectedDishForDetail = dish
    }

    public func clearRecentlyViewed() {
        favoritesRepository.clearRecentlyViewed()
        self.recentlyViewedDishes = []
    }
}
