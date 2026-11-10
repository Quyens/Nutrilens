//
//  AddHydrationUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol AddHydrationUseCaseProtocol: Sendable {
    func execute(amountLiters: Double, timestamp: Date, notes: String?) async throws -> HydrationRecord
}

public final class AddHydrationUseCase: AddHydrationUseCaseProtocol, Sendable {
    private let repository: HydrationRepositoryProtocol

    public init(repository: HydrationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(amountLiters: Double, timestamp: Date = Date(), notes: String? = nil) async throws -> HydrationRecord {
        guard amountLiters > 0 else {
            throw AppError.invalidInput("Lượng nước uống phải lớn hơn 0.")
        }
        let record = HydrationRecord(timestamp: timestamp, amountLiters: amountLiters, notes: notes)
        try await repository.saveHydration(record)
        return record
    }
}
