//
//  GetCustomFoodsUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetCustomFoodsUseCaseProtocol: Sendable {
    func execute() async throws -> [CustomFood]
    func execute(query: String) async throws -> [CustomFood]
    func execute(id: UUID) async throws -> CustomFood?
}

public final class GetCustomFoodsUseCase: GetCustomFoodsUseCaseProtocol, Sendable {
    private let repository: CustomFoodRepositoryProtocol

    public init(repository: CustomFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [CustomFood] {
        try await repository.fetchAllCustomFoods()
    }

    public func execute(query: String) async throws -> [CustomFood] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return try await repository.fetchAllCustomFoods()
        }
        return try await repository.searchCustomFoods(query: query)
    }

    public func execute(id: UUID) async throws -> CustomFood? {
        try await repository.fetchCustomFood(id: id)
    }
}

