//
//  WeeklyMealPlan.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a complete 7-day planned meal schedule.
//

import Foundation

public struct WeeklyMealPlan: Equatable, Hashable, Sendable {
    public let weekStartDate: Date
    public let weekEndDate: Date
    public var plannedMeals: [PlannedMeal]

    public init(
        weekStartDate: Date,
        weekEndDate: Date,
        plannedMeals: [PlannedMeal] = []
    ) {
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.plannedMeals = plannedMeals
    }

    public var totalPlannedMealsCount: Int {
        plannedMeals.count
    }

    public var completedMealsCount: Int {
        plannedMeals.filter { $0.status == .completed }.count
    }

    public var plannedOnlyMealsCount: Int {
        plannedMeals.filter { $0.status == .planned }.count
    }

    public var skippedMealsCount: Int {
        plannedMeals.filter { $0.status == .skipped }.count
    }

    /// Total nutrition estimated across the entire 7-day week
    public var totalWeeklyNutrition: PlannedNutritionSnapshot {
        plannedMeals.reduce(.zero) { $0 + $1.totalNutrition }
    }

    /// Retrieves planned meals for a specific calendar day
    public func meals(for date: Date, calendar: Calendar = .current) -> [PlannedMeal] {
        plannedMeals.filter { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
    }

    /// Retrieves planned meals for a specific calendar day and meal category
    public func meals(for date: Date, category: PlannedMealCategory, calendar: Calendar = .current) -> [PlannedMeal] {
        plannedMeals.filter {
            calendar.isDate($0.scheduledDate, inSameDayAs: date) && $0.mealCategory == category
        }
    }

    /// Estimated planned nutrition for a single day
    public func estimatedDailyNutrition(for date: Date, calendar: Calendar = .current) -> PlannedNutritionSnapshot {
        meals(for: date, calendar: calendar).reduce(.zero) { $0 + $1.totalNutrition }
    }

    /// Indicates whether a given day has any planned meals
    public func hasMeals(for date: Date, calendar: Calendar = .current) -> Bool {
        !meals(for: date, calendar: calendar).isEmpty
    }

    /// Indicates whether all meals for a given day are completed
    public func isDayCompleted(for date: Date, calendar: Calendar = .current) -> Bool {
        let dayMeals = meals(for: date, calendar: calendar)
        guard !dayMeals.isEmpty else { return false }
        return dayMeals.allSatisfy { $0.status == .completed }
    }
}

