//
//  AuthenticationRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Protocol abstraction decoupling presentation and use cases from auth data sources.
//

import Foundation

public protocol AuthenticationRepositoryProtocol: Sendable {
    /// Retrieves the current active authentication session from persistent storage
    func getCurrentSession() async throws -> AuthenticationSession

    /// Registers a new user with email, password and display name
    func register(email: String, password: String, displayName: String) async throws -> AuthenticationSession

    /// Logs in an existing user with email and password
    func login(email: String, password: String) async throws -> AuthenticationSession

    /// Performs Sign in with Apple using identity token and cryptographic nonce
    func signInWithApple(idToken: String, nonce: String, fullName: String?) async throws -> AuthenticationSession

    /// Requests a password reset for the specified email
    func requestPasswordReset(email: String) async throws

    /// Logs out the currently active session and clears session tokens
    func logout() async throws

    /// Permanently deletes the active user account and associated session
    func deleteAccount() async throws

    /// Enters anonymous Guest Mode preserving all local SwiftData records
    func continueAsGuest() async throws -> AuthenticationSession
}
