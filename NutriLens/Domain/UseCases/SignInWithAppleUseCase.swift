//
//  SignInWithAppleUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol SignInWithAppleUseCaseProtocol: Sendable {
    func execute(idToken: String, nonce: String, fullName: String?) async throws -> AuthenticationSession
}

public final class SignInWithAppleUseCase: SignInWithAppleUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(idToken: String, nonce: String, fullName: String?) async throws -> AuthenticationSession {
        guard !idToken.isEmpty else {
            throw AuthError.unauthorized
        }
        return try await repository.signInWithApple(idToken: idToken, nonce: nonce, fullName: fullName)
    }
}
