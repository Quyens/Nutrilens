//
//  MealRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol MealRepositoryProtocol: Sendable {
    func fetchMeals(for date: Date) async throws -> [MealRecord]
    func fetchAllMeals() async throws -> [MealRecord]
    func saveMeal(_ meal: MealRecord) async throws
    func deleteMeal(id: UUID) async throws
    func fetchDailySummary(for date: Date) async throws -> NutritionSummary
}
