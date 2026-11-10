//
//  GetHydrationHistoryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetHydrationHistoryUseCaseProtocol: Sendable {
    func execute(from startDate: Date, to endDate: Date) async throws -> [HydrationRecord]
}

public final class GetHydrationHistoryUseCase: GetHydrationHistoryUseCaseProtocol, Sendable {
    private let repository: HydrationRepositoryProtocol

    public init(repository: HydrationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(from startDate: Date, to endDate: Date) async throws -> [HydrationRecord] {
        try await repository.fetchHydration(from: startDate, to: endDate)
    }
}
