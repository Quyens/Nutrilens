//
//  LoginUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol LoginUseCaseProtocol: Sendable {
    func execute(email: String, password: String) async throws -> AuthenticationSession
}

public final class LoginUseCase: LoginUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> AuthenticationSession {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanEmail.isEmpty else {
            throw AuthError.invalidEmail
        }

        guard isValidEmail(cleanEmail) else {
            throw AuthError.invalidEmail
        }

        guard !password.isEmpty else {
            throw AuthError.wrongPassword
        }

        return try await repository.login(email: cleanEmail, password: password)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
