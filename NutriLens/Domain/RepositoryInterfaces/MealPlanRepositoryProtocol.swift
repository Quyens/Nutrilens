//
//  MealPlanRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Repository interface for weekly meal plan persistence and operations.
//

import Foundation

public protocol MealPlanRepositoryProtocol: Sendable {
    /// Fetches all planned meals scheduled between weekStartDate and weekEndDate (inclusive)
    func getPlannedMeals(forWeekStarting weekStartDate: Date, weekEndDate: Date) async throws -> [PlannedMeal]

    /// Fetches planned meals for a specific calendar day
    func getPlannedMeals(forDay date: Date) async throws -> [PlannedMeal]

    /// Fetches a specific planned meal by ID
    func getPlannedMeal(byId id: UUID) async throws -> PlannedMeal?

    /// Saves a newly created planned meal
    func savePlannedMeal(_ meal: PlannedMeal) async throws

    /// Updates an existing planned meal
    func updatePlannedMeal(_ meal: PlannedMeal) async throws

    /// Deletes a planned meal by ID
    func deletePlannedMeal(id: UUID) async throws

    /// Marks a planned meal as completed, linking it to the created diary record
    func markMealCompleted(id: UUID, linkedDiaryRecordId: UUID) async throws

    /// Marks a planned meal as skipped
    func markMealSkipped(id: UUID) async throws

    /// Restores a completed or skipped meal back to planned status
    func restorePlannedStatus(id: UUID) async throws

    /// Fetches the complete WeeklyMealPlan for the 7-day week containing the given date
    func getWeeklyPlan(forWeekContaining date: Date) async throws -> WeeklyMealPlan
}

