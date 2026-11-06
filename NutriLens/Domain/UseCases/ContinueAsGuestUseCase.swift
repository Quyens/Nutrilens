//
//  ContinueAsGuestUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol ContinueAsGuestUseCaseProtocol: Sendable {
    func execute() async throws -> AuthenticationSession
}

public final class ContinueAsGuestUseCase: ContinueAsGuestUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> AuthenticationSession {
        try await repository.continueAsGuest()
    }
}
