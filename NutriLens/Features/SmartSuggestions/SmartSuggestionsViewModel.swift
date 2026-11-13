//
//  SmartSuggestionsViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation state manager for smart meal suggestions, preferences, and weekly planner integration.
//

import Foundation
import SwiftUI

@MainActor
public final class SmartSuggestionsViewModel: ObservableObject {
    private let useCase: SmartMealSuggestionsUseCaseProtocol
    private let hapticService: HapticFeedbackServiceProtocol

    // MARK: - Published State
    @Published public var suggestions: [MealSuggestion] = []
    @Published public var userProfile: UserDietaryProfile = UserDietaryProfile()
    @Published public var selectedMealCategory: PlannedMealCategory? = nil
    @Published public var selectedDietaryStyle: DietaryPreferenceType? = nil
    @Published public var selectedFoodCategory: String = "Tất cả"
    @Published public var favoriteOnly: Bool = false
    @Published public var excludeAllergens: Bool = true
    @Published public var searchText: String = ""
    @Published public var targetDate: Date = Date()

    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var successMessage: String? = nil

    // Sheets presentation
    @Published public var explanationSuggestion: MealSuggestion? = nil
    @Published public var ingredientReviewSuggestion: MealSuggestion? = nil
    @Published public var addToPlanSuggestion: MealSuggestion? = nil
    @Published public var isShowingPreferencesSheet: Bool = false

    public let availableFoodCategories: [String] = [
        "Tất cả", "Cơm", "Món Nước", "Bún & Mì", "Món Mặn", "Canh", "Món Bánh", "Bánh Mì", "Xôi", "Khai Vị", "Tráng Miệng"
    ]

    public init(
        useCase: SmartMealSuggestionsUseCaseProtocol,
        hapticService: HapticFeedbackServiceProtocol = HapticFeedbackService.shared,
        initialCategory: PlannedMealCategory? = nil,
        initialDate: Date = Date()
    ) {
        self.useCase = useCase
        self.hapticService = hapticService
        self.selectedMealCategory = initialCategory
        self.targetDate = initialDate
    }

    // MARK: - Actions
    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            userProfile = try await useCase.getDietaryProfile()
            if selectedDietaryStyle == nil, let firstStyle = userProfile.dietaryPreferences.first {
                selectedDietaryStyle = firstStyle
            }
            await fetchSuggestionsInternal()
        } catch {
            errorMessage = "Không thể tải gợi ý món ăn: \(error.localizedDescription)"
        }

        isLoading = false
    }

    public func refresh() async {
        hapticService.impact(.light)
        await loadData()
    }

    public func selectMealCategory(_ category: PlannedMealCategory?) {
        hapticService.selection()
        if selectedMealCategory == category {
            selectedMealCategory = nil
        } else {
            selectedMealCategory = category
        }
        Task { await fetchSuggestionsInternal() }
    }

    public func selectDietaryStyle(_ style: DietaryPreferenceType?) {
        hapticService.selection()
        if selectedDietaryStyle == style {
            selectedDietaryStyle = nil
        } else {
            selectedDietaryStyle = style
        }
        Task { await fetchSuggestionsInternal() }
    }

    public func selectFoodCategory(_ cat: String) {
        hapticService.selection()
        selectedFoodCategory = cat
        Task { await fetchSuggestionsInternal() }
    }

    public func toggleFavoriteFilter() {
        hapticService.selection()
        favoriteOnly.toggle()
        Task { await fetchSuggestionsInternal() }
    }

    public func updateSearchText(_ text: String) {
        searchText = text
        Task { await fetchSuggestionsInternal() }
    }

    public func toggleFavorite(for suggestion: MealSuggestion) {
        hapticService.impact(.medium)
        Task {
            do {
                let newFavStatus = try await useCase.toggleFavorite(suggestion: suggestion)
                if let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) {
                    var updated = suggestions[index]
                    updated.isFavorite = newFavStatus
                    suggestions[index] = updated
                }
            } catch {
                errorMessage = "Không thể cập nhật yêu thích"
            }
        }
    }

    public func saveDietaryProfile(_ updatedProfile: UserDietaryProfile) {
        isLoading = true
        Task {
            do {
                try await useCase.saveDietaryProfile(updatedProfile)
                userProfile = updatedProfile
                isShowingPreferencesSheet = false
                hapticService.notification(.success)
                successMessage = "Đã cập nhật sở thích dinh dưỡng"
                await fetchSuggestionsInternal()
            } catch {
                errorMessage = "Không thể lưu sở thích: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    public func clearDietaryProfile() {
        Task {
            do {
                try await useCase.clearDietaryProfile()
                userProfile = UserDietaryProfile()
                hapticService.notification(.success)
                successMessage = "Đã đặt lại sở thích về mặc định"
                await fetchSuggestionsInternal()
            } catch {
                errorMessage = "Không thể đặt lại sở thích"
            }
        }
    }

    public func confirmAddToWeeklyPlan(
        suggestion: MealSuggestion,
        date: Date,
        category: PlannedMealCategory,
        multiplier: Double,
        notes: String?
    ) {
        isLoading = true
        Task {
            do {
                _ = try await useCase.addSuggestionToWeeklyPlan(
                    suggestion: suggestion,
                    targetDate: date,
                    mealCategory: category,
                    servingMultiplier: multiplier,
                    notes: notes
                )
                hapticService.notification(.success)
                addToPlanSuggestion = nil
                successMessage = "Đã thêm '\(suggestion.displayName)' vào kế hoạch \(category.vietnameseName.lowercased())!"
            } catch {
                hapticService.notification(.error)
                errorMessage = "Không thể thêm vào kế hoạch: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    // MARK: - Internal Query
    private func fetchSuggestionsInternal() async {
        let filter = SmartSuggestionsFilter(
            mealCategory: selectedMealCategory,
            foodCategory: selectedFoodCategory == "Tất cả" ? nil : selectedFoodCategory,
            favoriteOnly: favoriteOnly,
            activeDietaryStyle: selectedDietaryStyle,
            excludeKnownAllergens: excludeAllergens,
            searchQuery: searchText
        )

        do {
            suggestions = try await useCase.getSuggestions(filter: filter, targetDate: targetDate)
        } catch {
            errorMessage = "Lỗi tính toán gợi ý: \(error.localizedDescription)"
        }
    }
}

