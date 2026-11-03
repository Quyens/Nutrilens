//
//  MealHistoryViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Coordinates Meal Diary V2: Weekly Calendar, Grouped Meals, Real-time Aggregates, Search & Filters, and Full CRUD.
//

import Foundation
import SwiftUI

@MainActor
public final class MealHistoryViewModel: ObservableObject {
    // MARK: - State
    @Published public private(set) var state: AsyncState<[MealRecord]> = .idle
    @Published public var selectedDate: Date = Date()
    @Published public var searchQuery: String = ""
    @Published public var selectedFilter: MealType? = nil
    @Published public var isSearching: Bool = false

    // Presentation States
    @Published public var selectedMealForDetails: MealRecord? = nil
    @Published public var mealBeingEdited: MealRecord? = nil
    @Published public var mealPendingDeletion: MealRecord? = nil
    @Published public var categoryForQuickAdd: MealType? = nil
    @Published public var showingDeleteConfirmation: Bool = false

    // Dependencies
    private let getMealHistoryUseCase: GetMealHistoryUseCaseProtocol

    public init(getMealHistoryUseCase: GetMealHistoryUseCaseProtocol) {
        self.getMealHistoryUseCase = getMealHistoryUseCase
    }

    // MARK: - Calendar Computations

    /// Returns the 7 days of the week containing selectedDate (Monday to Sunday)
    public var currentWeekDates: [Date] {
        let calendar = Calendar.current
        var startOfWeek = selectedDate
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: selectedDate)

        // Ensure week starts on Monday
        let weekday = calendar.component(.weekday, from: startOfWeek)
        // In Gregorian calendar: 1 is Sunday, 2 is Monday
        let daysToMonday = (weekday == 1) ? -6 : (2 - weekday)
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: startOfWeek) else {
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: selectedDate) }
        }

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    /// Set of day timestamps that have at least one logged meal
    public var daysWithLoggedMeals: Set<String> {
        guard let list = state.value else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(list.map { formatter.string(from: $0.timestamp) })
    }

    public func hasMeals(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return daysWithLoggedMeals.contains(formatter.string(from: date))
    }

    // MARK: - Filtered Meals

    /// All meals for the selected day, regardless of category filter or search query
    public var allDayMeals: [MealRecord] {
        guard let list = state.value else { return [] }
        let calendar = Calendar.current
        return list.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    /// Meals for the selected day matching current search query and category filter
    public var filteredDayMeals: [MealRecord] {
        var result = allDayMeals

        if let filter = selectedFilter {
            result = result.filter { $0.mealType == filter }
        }

        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !cleanQuery.isEmpty {
            result = result.filter { meal in
                let titleMatch = meal.displayTitle.lowercased().contains(cleanQuery)
                let itemMatch = meal.items.contains {
                    $0.vietnameseName.lowercased().contains(cleanQuery) ||
                    $0.name.lowercased().contains(cleanQuery)
                }
                let notesMatch = (meal.notes ?? "").lowercased().contains(cleanQuery)
                return titleMatch || itemMatch || notesMatch
            }
        }

        return result
    }

    /// Meals in a specific category for the selected day (respecting search query)
    public func meals(for category: MealType) -> [MealRecord] {
        let inCategory = allDayMeals.filter { $0.mealType == category }
        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanQuery.isEmpty else { return inCategory }

        return inCategory.filter { meal in
            let titleMatch = meal.displayTitle.lowercased().contains(cleanQuery)
            let itemMatch = meal.items.contains {
                $0.vietnameseName.lowercased().contains(cleanQuery) ||
                $0.name.lowercased().contains(cleanQuery)
            }
            let notesMatch = (meal.notes ?? "").lowercased().contains(cleanQuery)
            return titleMatch || itemMatch || notesMatch
        }
    }

    public func categoryCalories(for category: MealType) -> Double {
        allDayMeals
            .filter { $0.mealType == category }
            .reduce(0) { $0 + $1.totalCalories }
    }

    // MARK: - Daily Nutrition Aggregates

    public var totalCalories: Double {
        allDayMeals.reduce(0) { $0 + $1.totalCalories }
    }

    public var totalProtein: Double {
        allDayMeals.reduce(0) { $0 + $1.totalProteinGrams }
    }

    public var totalCarbs: Double {
        allDayMeals.reduce(0) { $0 + $1.totalCarbGrams }
    }

    public var totalFat: Double {
        allDayMeals.reduce(0) { $0 + $1.totalFatGrams }
    }

    public var totalFiber: Double {
        allDayMeals.reduce(0) { $0 + $1.totalFiberGrams }
    }

    public var targetCalories: Double { 2000 }
    public var targetProtein: Double { 125 }
    public var targetCarbs: Double { 250 }
    public var targetFat: Double { 55 }
    public var targetFiber: Double { 30 }

    public var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(totalCalories / targetCalories, 1.0)
    }

    public var remainingCalories: Double {
        max(0, targetCalories - totalCalories)
    }

    // MARK: - Actions

    public func selectDate(_ date: Date) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.selectedDate = date
    }

    public func shiftDay(by offset: Int) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) {
            self.selectedDate = newDate
        }
    }

    public func shiftWeek(by offset: Int) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        if let newDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: selectedDate) {
            self.selectedDate = newDate
        }
    }

    public func selectToday() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        self.selectedDate = Date()
    }

    public func loadHistory() async {
        state = .loading
        do {
            let meals = try await getMealHistoryUseCase.execute()
            state = .success(meals)
        } catch let err as AppError {
            state = .failure(err)
        } catch {
            state = .failure(.unknown(error.localizedDescription))
        }
    }

    public func updateMeal(_ meal: MealRecord) async {
        do {
            try await getMealHistoryUseCase.update(meal: meal)
            await loadHistory()

            // If selected in detail view, update active detail record as well
            if selectedMealForDetails?.id == meal.id {
                selectedMealForDetails = meal
            }
        } catch {
            AppLogger.data.error("Failed to update meal: \(error.localizedDescription)")
        }
    }

    public func deleteMeal(id: UUID) async {
        do {
            try await getMealHistoryUseCase.delete(id: id)
            if selectedMealForDetails?.id == id {
                selectedMealForDetails = nil
            }
            await loadHistory()
        } catch {
            AppLogger.data.error("Failed to delete meal: \(error.localizedDescription)")
        }
    }

    public func confirmDeletion(for meal: MealRecord) {
        mealPendingDeletion = meal
        showingDeleteConfirmation = true
    }

    public func executePendingDeletion() async {
        guard let meal = mealPendingDeletion else { return }
        await deleteMeal(id: meal.id)
        mealPendingDeletion = nil
        showingDeleteConfirmation = false
    }

    /// Quick-adds a dish profile into SwiftData for the currently selected date and category
    public func quickAdd(dish: VietnameseDishProfile, category: MealType, servingGrams: Double) async {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let nowComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        components.hour = nowComponents.hour
        components.minute = nowComponents.minute
        components.second = nowComponents.second
        let timestamp = calendar.date(from: components) ?? selectedDate

        let foodItem = dish.toFoodItem(confidence: 1.0, targetGrams: servingGrams)
        let newRecord = MealRecord(
            timestamp: timestamp,
            mealType: category,
            items: [foodItem],
            notes: "Ghi nhận từ thư viện món Việt",
            imagePath: dish.slug
        )

        do {
            try await getMealHistoryUseCase.update(meal: newRecord)
            await loadHistory()
        } catch {
            AppLogger.data.error("Failed to quick add meal: \(error.localizedDescription)")
        }
    }
}
