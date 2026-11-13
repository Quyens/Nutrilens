//
//  CustomFoodRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol CustomFoodRepositoryProtocol: Sendable {
    func fetchAllCustomFoods() async throws -> [CustomFood]
    func fetchCustomFood(id: UUID) async throws -> CustomFood?
    func searchCustomFoods(query: String) async throws -> [CustomFood]
    func saveCustomFood(_ food: CustomFood) async throws
    func updateCustomFood(_ food: CustomFood) async throws
    func deleteCustomFood(id: UUID) async throws
    func toggleFavorite(id: UUID) async throws
}

