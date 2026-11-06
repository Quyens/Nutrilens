//
//  RequestPasswordResetUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol RequestPasswordResetUseCaseProtocol: Sendable {
    func execute(email: String) async throws
}

public final class RequestPasswordResetUseCase: RequestPasswordResetUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String) async throws {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(cleanEmail) else {
            throw AuthError.invalidEmail
        }
        try await repository.requestPasswordReset(email: cleanEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
