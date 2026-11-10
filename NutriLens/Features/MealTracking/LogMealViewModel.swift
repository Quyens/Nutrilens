//
//  LogMealViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 02 Advanced Multi-Item Meal Logging ViewModel with Vietnamese Food Database search,
//  dynamic portion scaling, custom item entry, and aggregate nutrition calculation.
//

import Foundation
import SwiftUI

// MARK: - Staged Meal Item
public struct StagedMealItem: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var vietnameseName: String
    public var sourceDishSlug: String?
    public var portionGrams: Double
    public var servingUnit: String
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double
    public var isCustom: Bool

    // Base values for portion scaling
    public var standardServingGrams: Double
    public var standardCalories: Double
    public var standardProtein: Double
    public var standardCarbs: Double
    public var standardFat: Double
    public var standardFiber: Double

    public init(
        id: UUID = UUID(),
        name: String,
        vietnameseName: String,
        sourceDishSlug: String? = nil,
        portionGrams: Double,
        servingUnit: String = "g",
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double = 0,
        isCustom: Bool = false,
        standardServingGrams: Double,
        standardCalories: Double,
        standardProtein: Double,
        standardCarbs: Double,
        standardFat: Double,
        standardFiber: Double = 0
    ) {
        self.id = id
        self.name = name
        self.vietnameseName = vietnameseName
        self.sourceDishSlug = sourceDishSlug
        self.portionGrams = portionGrams
        self.servingUnit = servingUnit
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.isCustom = isCustom
        self.standardServingGrams = max(standardServingGrams, 1.0)
        self.standardCalories = standardCalories
        self.standardProtein = standardProtein
        self.standardCarbs = standardCarbs
        self.standardFat = standardFat
        self.standardFiber = standardFiber
    }

    public mutating func updatePortion(grams: Double) {
        self.portionGrams = max(grams, 10.0)
        let ratio = self.portionGrams / self.standardServingGrams
        self.calories = (self.standardCalories * ratio).rounded()
        self.proteinGrams = ((self.standardProtein * ratio) * 10).rounded() / 10
        self.carbGrams = ((self.standardCarbs * ratio) * 10).rounded() / 10
        self.fatGrams = ((self.standardFat * ratio) * 10).rounded() / 10
        self.fiberGrams = ((self.standardFiber * ratio) * 10).rounded() / 10
    }

    public func toDomain() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            vietnameseName: vietnameseName,
            confidence: 1.0,
            servingSizeGrams: portionGrams,
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams
        )
    }
}

// MARK: - ViewModel
@MainActor
public final class LogMealViewModel: ObservableObject {
    // Staged items in this meal
    @Published public var stagedItems: [StagedMealItem] = []

    // Meal Metadata
    @Published public var selectedMealType: MealType = .lunch
    @Published public var selectedDate: Date = Date()
    @Published public var mealNotes: String = ""
    @Published public private(set) var isSaving: Bool = false
    @Published public var errorMessage: String? = nil

    // Food Catalog Search State
    @Published public var searchQuery: String = ""
    @Published public var selectedCategoryFilter: String = "Tất cả"
    @Published public var selectedDishForPortion: VietnameseDishProfile? = nil
    @Published public var pendingPortionGrams: Double = 400

    // Custom Food Entry Modal State
    @Published public var isPresentingCustomItemSheet: Bool = false
    @Published public var customName: String = ""
    @Published public var customPortionGramsText: String = "200"
    @Published public var customCaloriesText: String = ""
    @Published public var customProteinText: String = ""
    @Published public var customCarbsText: String = ""
    @Published public var customFatText: String = ""
    @Published public var customFiberText: String = ""

    // Dependencies
    private let logMealUseCase: LogMealUseCaseProtocol
    public let unitFormattingService: UnitFormattingServiceProtocol
    public let hapticFeedbackService: HapticFeedbackServiceProtocol
    private let onDismiss: () -> Void

    public init(
        logMealUseCase: LogMealUseCaseProtocol,
        unitFormattingService: UnitFormattingServiceProtocol = UnitFormattingService.shared,
        hapticFeedbackService: HapticFeedbackServiceProtocol = HapticFeedbackService.shared,
        initialMealType: MealType = .lunch,
        initialDate: Date = Date(),
        onDismiss: @escaping () -> Void = {}
    ) {
        self.logMealUseCase = logMealUseCase
        self.unitFormattingService = unitFormattingService
        self.hapticFeedbackService = hapticFeedbackService
        self.selectedMealType = initialMealType
        self.selectedDate = initialDate
        self.onDismiss = onDismiss
    }

    // MARK: - Calculated Totals
    public var totalCalories: Double {
        stagedItems.reduce(0) { $0 + $1.calories }
    }

    public var totalProtein: Double {
        let val = stagedItems.reduce(0.0) { $0 + $1.proteinGrams }
        return (val * 10).rounded() / 10
    }

    public var totalCarbs: Double {
        let val = stagedItems.reduce(0.0) { $0 + $1.carbGrams }
        return (val * 10).rounded() / 10
    }

    public var totalFat: Double {
        let val = stagedItems.reduce(0.0) { $0 + $1.fatGrams }
        return (val * 10).rounded() / 10
    }

    public var totalFiber: Double {
        let val = stagedItems.reduce(0.0) { $0 + $1.fiberGrams }
        return (val * 10).rounded() / 10
    }

    public var totalGrams: Double {
        stagedItems.reduce(0) { $0 + $1.portionGrams }
    }

    public var canSave: Bool {
        !stagedItems.isEmpty && !isSaving
    }

    // MARK: - Search Filtering
    public var filteredCatalogDishes: [VietnameseDishProfile] {
        let clean = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        let baseDishes = VietnameseNutritionDatabase.dishes

        let categoryFiltered: [VietnameseDishProfile]
        if selectedCategoryFilter == "Tất cả" {
            categoryFiltered = baseDishes
        } else {
            categoryFiltered = baseDishes.filter { $0.category == selectedCategoryFilter }
        }

        if clean.isEmpty {
            return categoryFiltered
        }

        return categoryFiltered.filter { dish in
            let vnNameFolded = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let enNameFolded = dish.englishName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let categoryFolded = dish.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()

            let matchName = vnNameFolded.contains(clean) || enNameFolded.contains(clean) || categoryFolded.contains(clean)
            let matchKeywords = dish.keywords.contains { kw in
                kw.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(clean)
            }
            return matchName || matchKeywords
        }
    }

    public var availableCategories: [String] {
        var categories = ["Tất cả"]
        let unique = Array(Set(VietnameseNutritionDatabase.dishes.map { $0.category })).sorted()
        categories.append(contentsOf: unique)
        return categories
    }

    // MARK: - Staged Item Management
    public func addDishFromDatabase(_ dish: VietnameseDishProfile, grams: Double) {
        hapticFeedbackService.impact(.medium)
        let ratio = max(grams, 10.0) / max(dish.standardServingGrams, 1.0)
        let cal = (dish.caloriesPerServing * ratio).rounded()
        let pro = ((dish.proteinPerServing * ratio) * 10).rounded() / 10
        let carb = ((dish.carbPerServing * ratio) * 10).rounded() / 10
        let fat = ((dish.fatPerServing * ratio) * 10).rounded() / 10
        let fiber = ((dish.fiberPerServing * ratio) * 10).rounded() / 10

        let item = StagedMealItem(
            name: dish.vietnameseName,
            vietnameseName: dish.vietnameseName,
            sourceDishSlug: dish.slug,
            portionGrams: grams,
            servingUnit: "g",
            calories: cal,
            proteinGrams: pro,
            carbGrams: carb,
            fatGrams: fat,
            fiberGrams: fiber,
            isCustom: false,
            standardServingGrams: dish.standardServingGrams,
            standardCalories: dish.caloriesPerServing,
            standardProtein: dish.proteinPerServing,
            standardCarbs: dish.carbPerServing,
            standardFat: dish.fatPerServing,
            standardFiber: dish.fiberPerServing
        )

        stagedItems.append(item)
        errorMessage = nil
    }

    public func addCustomItem() {
        let trimmedName = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Vui lòng nhập tên món ăn tùy chỉnh."
            hapticFeedbackService.notification(.error)
            return
        }

        hapticFeedbackService.impact(.medium)
        let grams = Double(customPortionGramsText) ?? 200
        let cal = Double(customCaloriesText) ?? 0
        let pro = Double(customProteinText) ?? 0
        let carb = Double(customCarbsText) ?? 0
        let fat = Double(customFatText) ?? 0
        let fiber = Double(customFiberText) ?? 0

        let item = StagedMealItem(
            name: trimmedName,
            vietnameseName: trimmedName,
            sourceDishSlug: nil,
            portionGrams: grams,
            servingUnit: "g",
            calories: cal,
            proteinGrams: pro,
            carbGrams: carb,
            fatGrams: fat,
            fiberGrams: fiber,
            isCustom: true,
            standardServingGrams: grams,
            standardCalories: cal,
            standardProtein: pro,
            standardCarbs: carb,
            standardFat: fat,
            standardFiber: fiber
        )

        stagedItems.append(item)
        resetCustomForm()
        isPresentingCustomItemSheet = false
        errorMessage = nil
    }

    public func updateItemPortion(id: UUID, newGrams: Double) {
        guard let index = stagedItems.firstIndex(where: { $0.id == id }) else { return }
        stagedItems[index].updatePortion(grams: newGrams)
        hapticFeedbackService.selection()
    }

    public func removeItem(id: UUID) {
        hapticFeedbackService.impact(.light)
        stagedItems.removeAll { $0.id == id }
    }

    public func resetCustomForm() {
        customName = ""
        customPortionGramsText = "200"
        customCaloriesText = ""
        customProteinText = ""
        customCarbsText = ""
        customFatText = ""
        customFiberText = ""
    }

    // MARK: - Save Meal to SwiftData
    @discardableResult
    public func saveMealAsync() async -> Bool {
        guard canSave else {
            if stagedItems.isEmpty {
                errorMessage = "Vui lòng thêm ít nhất một món ăn vào bữa."
                hapticFeedbackService.notification(.warning)
            }
            return false
        }

        isSaving = true
        errorMessage = nil
        hapticFeedbackService.notification(.success)

        let foodItems = stagedItems.map { $0.toDomain() }
        let mealRecord = MealRecord(
            timestamp: selectedDate,
            mealType: selectedMealType,
            items: foodItems,
            notes: mealNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : mealNotes
        )

        do {
            try await logMealUseCase.execute(meal: mealRecord)
            isSaving = false
            NotificationCenter.default.post(name: NSNotification.Name("NutriLensMealDiaryChanged"), object: nil)
            onDismiss()
            return true
        } catch {
            isSaving = false
            errorMessage = "Không thể lưu bữa ăn: \(error.localizedDescription)"
            hapticFeedbackService.notification(.error)
            return false
        }
    }

    public func saveMeal() {
        Task {
            await saveMealAsync()
        }
    }
}
