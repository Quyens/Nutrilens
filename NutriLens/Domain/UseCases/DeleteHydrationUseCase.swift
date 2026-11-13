//
//  DeleteHydrationUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol DeleteHydrationUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws
}

public final class DeleteHydrationUseCase: DeleteHydrationUseCaseProtocol, Sendable {
    private let repository: HydrationRepositoryProtocol

    public init(repository: HydrationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteHydration(id: id)
    }
}

