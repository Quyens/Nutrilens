//
//  RegisterUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol RegisterUseCaseProtocol: Sendable {
    func execute(email: String, password: String, confirmPassword: String, displayName: String) async throws -> AuthenticationSession
}

public final class RegisterUseCase: RegisterUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        email: String,
        password: String,
        confirmPassword: String,
        displayName: String
    ) async throws -> AuthenticationSession {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(cleanEmail) else {
            throw AuthError.invalidEmail
        }

        if let weakReason = validatePassword(password) {
            throw AuthError.weakPassword(reason: weakReason)
        }

        guard password == confirmPassword else {
            throw AuthError.passwordsDoNotMatch
        }

        let finalName = cleanName.isEmpty ? "Người dùng NutriLens" : cleanName
        return try await repository.register(email: cleanEmail, password: password, displayName: finalName)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    private func validatePassword(_ pass: String) -> String? {
        if pass.count < 8 {
            return "cần ít nhất 8 ký tự."
        }
        let hasLetters = pass.range(of: #"[A-Za-z]"#, options: .regularExpression) != nil
        let hasNumbers = pass.range(of: #"[0-9]"#, options: .regularExpression) != nil
        if !hasLetters || !hasNumbers {
            return "phải bao gồm cả chữ cái và chữ số."
        }
        return nil
    }
}
