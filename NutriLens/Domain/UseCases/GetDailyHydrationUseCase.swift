//
//  GetDailyHydrationUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetDailyHydrationUseCaseProtocol: Sendable {
    func execute(for date: Date) async throws -> (totalLiters: Double, records: [HydrationRecord])
}

public final class GetDailyHydrationUseCase: GetDailyHydrationUseCaseProtocol, Sendable {
    private let repository: HydrationRepositoryProtocol

    public init(repository: HydrationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(for date: Date = Date()) async throws -> (totalLiters: Double, records: [HydrationRecord]) {
        try await repository.migrateLegacyUserDefaultsIfNeeded()
        let records = try await repository.fetchHydration(for: date)
        let total = records.reduce(0.0) { $0 + $1.amountLiters }
        let rounded = (total * 100).rounded() / 100
        return (totalLiters: rounded, records: records)
    }
}
