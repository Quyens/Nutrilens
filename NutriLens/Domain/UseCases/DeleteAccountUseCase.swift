//
//  DeleteAccountUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol DeleteAccountUseCaseProtocol: Sendable {
    func execute() async throws
}

public final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol, Sendable {
    private let repository: AuthenticationRepositoryProtocol

    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws {
        try await repository.deleteAccount()
    }
}
