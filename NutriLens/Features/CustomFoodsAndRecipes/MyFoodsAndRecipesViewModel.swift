//
//  MyFoodsAndRecipesViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Personal Food Library & Recipe Management ViewModel.
//

import Foundation
import SwiftUI
import Combine

public enum PersonalLibraryTab: String, CaseIterable, Identifiable {
    case customFoods = "Món của bạn"
    case recipes = "Công thức"

    public var id: String { rawValue }
}

@MainActor
public final class MyFoodsAndRecipesViewModel: ObservableObject {
    // MARK: - State
    @Published public var selectedTab: PersonalLibraryTab = .customFoods
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: String = "Tất cả"
    @Published public var showFavoritesOnly: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    // Data lists
    @Published public var customFoods: [CustomFood] = []
    @Published public var recipes: [Recipe] = []

    // Navigation / Presentation
    @Published public var isPresentingCreateFood: Bool = false
    @Published public var isPresentingCreateRecipe: Bool = false
    @Published public var selectedFoodForDetail: CustomFood? = nil
    @Published public var selectedRecipeForDetail: Recipe? = nil
    @Published public var foodToEdit: CustomFood? = nil
    @Published public var recipeToEdit: Recipe? = nil

    // Notification toast
    @Published public var toastMessage: String? = nil

    // MARK: - Dependencies
    private let getCustomFoodsUseCase: GetCustomFoodsUseCaseProtocol
    private let saveCustomFoodUseCase: SaveCustomFoodUseCaseProtocol
    private let deleteCustomFoodUseCase: DeleteCustomFoodUseCaseProtocol
    private let getRecipesUseCase: GetRecipesUseCaseProtocol
    private let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    private let deleteRecipeUseCase: DeleteRecipeUseCaseProtocol
    private let logMealUseCase: LogMealUseCaseProtocol
    public let unitFormatting: UnitFormattingServiceProtocol
    public let haptics: HapticFeedbackServiceProtocol

    public init(
        getCustomFoodsUseCase: GetCustomFoodsUseCaseProtocol,
        saveCustomFoodUseCase: SaveCustomFoodUseCaseProtocol,
        deleteCustomFoodUseCase: DeleteCustomFoodUseCaseProtocol,
        getRecipesUseCase: GetRecipesUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        deleteRecipeUseCase: DeleteRecipeUseCaseProtocol,
        logMealUseCase: LogMealUseCaseProtocol,
        unitFormatting: UnitFormattingServiceProtocol? = nil,
        haptics: HapticFeedbackServiceProtocol? = nil
    ) {
        self.getCustomFoodsUseCase = getCustomFoodsUseCase
        self.saveCustomFoodUseCase = saveCustomFoodUseCase
        self.deleteCustomFoodUseCase = deleteCustomFoodUseCase
        self.getRecipesUseCase = getRecipesUseCase
        self.saveRecipeUseCase = saveRecipeUseCase
        self.deleteRecipeUseCase = deleteRecipeUseCase
        self.logMealUseCase = logMealUseCase
        self.unitFormatting = unitFormatting ?? UnitFormattingService.shared
        self.haptics = haptics ?? HapticFeedbackService.shared
    }

    // MARK: - Filtered Custom Foods
    public var filteredCustomFoods: [CustomFood] {
        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        return customFoods.filter { food in
            if showFavoritesOnly && !food.isFavorite {
                return false
            }
            if selectedCategory != "Tất cả" && food.category != selectedCategory {
                return false
            }
            if cleanQuery.isEmpty {
                return true
            }
            let nameFolded = food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let brandFolded = (food.brand ?? "").folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let catFolded = food.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return nameFolded.contains(cleanQuery) || brandFolded.contains(cleanQuery) || catFolded.contains(cleanQuery)
        }
    }

    // MARK: - Filtered Recipes
    public var filteredRecipes: [Recipe] {
        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        return recipes.filter { recipe in
            if showFavoritesOnly && !recipe.isFavorite {
                return false
            }
            if cleanQuery.isEmpty {
                return true
            }
            let nameFolded = recipe.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let notesFolded = (recipe.notes ?? "").folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let ingredientMatch = recipe.ingredients.contains { ing in
                ing.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanQuery)
            }
            return nameFolded.contains(cleanQuery) || notesFolded.contains(cleanQuery) || ingredientMatch
        }
    }

    public var availableFoodCategories: [String] {
        var categories = ["Tất cả"]
        let unique = Array(Set(customFoods.map { $0.category })).sorted()
        categories.append(contentsOf: unique)
        return categories
    }

    // MARK: - Data Loading
    public func loadData() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                async let foodsTask = getCustomFoodsUseCase.execute()
                async let recipesTask = getRecipesUseCase.execute()
                let (foods, recs) = try await (foodsTask, recipesTask)
                self.customFoods = foods
                self.recipes = recs
            } catch {
                self.errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    // MARK: - Custom Food Actions
    public func toggleFavorite(for food: CustomFood) {
        haptics.selection()
        var updated = food
        updated.isFavorite.toggle()
        Task {
            do {
                try await saveCustomFoodUseCase.execute(updated)
                loadData()
            } catch {
                errorMessage = "Không thể cập nhật yêu thích: \(error.localizedDescription)"
            }
        }
    }

    public func deleteCustomFood(id: UUID) {
        haptics.impact(.medium)
        Task {
            do {
                try await deleteCustomFoodUseCase.execute(id: id)
                if selectedFoodForDetail?.id == id {
                    selectedFoodForDetail = nil
                }
                loadData()
                showToast("Đã xóa món ăn tùy chỉnh")
            } catch {
                errorMessage = "Không thể xóa món ăn: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Recipe Actions
    public func toggleFavorite(for recipe: Recipe) {
        haptics.selection()
        var updated = recipe
        updated.isFavorite.toggle()
        Task {
            do {
                try await saveRecipeUseCase.execute(updated)
                loadData()
            } catch {
                errorMessage = "Không thể cập nhật yêu thích: \(error.localizedDescription)"
            }
        }
    }

    public func deleteRecipe(id: UUID) {
        haptics.impact(.medium)
        Task {
            do {
                try await deleteRecipeUseCase.execute(id: id)
                if selectedRecipeForDetail?.id == id {
                    selectedRecipeForDetail = nil
                }
                loadData()
                showToast("Đã xóa công thức")
            } catch {
                errorMessage = "Không thể xóa công thức: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Quick Log to Meal Diary
    public func quickLogFoodToDiary(food: CustomFood, mealType: MealType = .lunch) {
        haptics.notification(.success)
        let item = food.toFoodItem()
        let meal = MealRecord(
            timestamp: Date(),
            mealType: mealType,
            items: [item],
            notes: "Ghi từ thư viện món cá nhân"
        )
        Task {
            do {
                try await logMealUseCase.execute(meal: meal)
                NotificationCenter.default.post(name: NSNotification.Name("NutriLensMealDiaryChanged"), object: nil)
                showToast("Đã ghi \"\(food.name)\" vào nhật ký bữa ăn")
            } catch {
                errorMessage = "Không thể ghi nhật ký: \(error.localizedDescription)"
            }
        }
    }

    public func quickLogRecipeToDiary(recipe: Recipe, servings: Double = 1.0, mealType: MealType = .lunch) {
        haptics.notification(.success)
        let item = recipe.toFoodItem(servingCount: servings)
        let meal = MealRecord(
            timestamp: Date(),
            mealType: mealType,
            items: [item],
            notes: "Ghi từ công thức: \(recipe.name) (\(Int(servings)) phần)"
        )
        Task {
            do {
                try await logMealUseCase.execute(meal: meal)
                NotificationCenter.default.post(name: NSNotification.Name("NutriLensMealDiaryChanged"), object: nil)
                showToast("Đã ghi \(Int(servings)) phần \"\(recipe.name)\" vào nhật ký")
            } catch {
                errorMessage = "Không thể ghi nhật ký: \(error.localizedDescription)"
            }
        }
    }

    private func showToast(_ msg: String) {
        withAnimation {
            toastMessage = msg
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run {
                withAnimation {
                    if toastMessage == msg {
                        toastMessage = nil
                    }
                }
            }
        }
    }
}
