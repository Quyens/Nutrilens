//
//  GetAuthSessionUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetAuthSessionUseCaseProtocol: Sendable {
    func execute() async throws -> AuthenticationSession
}

public final class GetAuthSessionUseCase: GetAuthSessionUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> AuthenticationSession {
        try await repository.getCurrentSession()
    }
}
