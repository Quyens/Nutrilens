//
//  GetPackagedFoodsUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Retrieves, filters, and searches packaged foods across user library and bundled catalogue.
//

import Foundation

public final class GetPackagedFoodsUseCase: Sendable {
    private let repository: PackagedFoodRepositoryProtocol

    public init(repository: PackagedFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func executeAll() async throws -> [PackagedFood] {
        try await repository.fetchAll()
    }

    public func executeSearch(query: String) async throws -> [PackagedFood] {
        try await repository.search(query: query)
    }

    public func executeRecentScans(limit: Int = 10) async throws -> [PackagedFood] {
        try await repository.fetchRecentScans(limit: limit)
    }

    public func executeToggleFavorite(id: UUID) async throws -> Bool {
        try await repository.toggleFavorite(id: id)
    }
}

