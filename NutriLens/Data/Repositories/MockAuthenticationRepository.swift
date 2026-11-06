//
//  MockAuthenticationRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  In-memory mock authentication repository explicitly labeled for testing and UI demonstration.
//

import Foundation

public final class MockAuthenticationRepository: AuthenticationRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var activeSession: AuthenticationSession
    private var registeredUsers: [String: (user: AuthUser, passwordHash: String)] = [:]
    public var shouldSimulateBackendFailure: Bool = false
    public var simulatedDelaySeconds: Double = 0.0

    public init(
        initialSession: AuthenticationSession = .unauthenticated,
        preloadDemoUser: Bool = true
    ) {
        self.activeSession = initialSession
        if preloadDemoUser {
            let demo = AuthUser.createMock(
                email: "demo@nutrilens.vn",
                displayName: "Người Dùng Thử Nghiệm",
                isEmailVerified: true
            )
            // Storing simple identifier hash in memory for mock comparison only
            self.registeredUsers["demo@nutrilens.vn"] = (demo, "NutriLens2026!")
        }
    }

    public func getCurrentSession() async throws -> AuthenticationSession {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        lock.lock()
        defer { lock.unlock() }
        return activeSession
    }

    public func register(email: String, password: String, displayName: String) async throws -> AuthenticationSession {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        if shouldSimulateBackendFailure {
            throw AuthError.networkUnavailable
        }

        lock.lock()
        defer { lock.unlock() }

        if registeredUsers[email] != nil {
            throw AuthError.emailAlreadyInUse
        }

        let newUser = AuthUser.createMock(
            email: email,
            displayName: displayName.isEmpty ? "Người dùng NutriLens" : displayName,
            isEmailVerified: false
        )
        registeredUsers[email] = (newUser, password)

        let session = AuthenticationSession.authenticated(user: newUser, accessToken: "mock_demo_token_\(UUID().uuidString)")
        activeSession = session
        return session
    }

    public func login(email: String, password: String) async throws -> AuthenticationSession {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        if shouldSimulateBackendFailure {
            throw AuthError.networkUnavailable
        }

        lock.lock()
        defer { lock.unlock() }

        guard let entry = registeredUsers[email] else {
            throw AuthError.userNotFound
        }

        guard entry.passwordHash == password else {
            throw AuthError.wrongPassword
        }

        var updatedUser = entry.user
        updatedUser.lastLoginAt = Date()
        registeredUsers[email] = (updatedUser, password)

        let session = AuthenticationSession.authenticated(user: updatedUser, accessToken: "mock_demo_token_\(UUID().uuidString)")
        activeSession = session
        return session
    }

    public func signInWithApple(idToken: String, nonce: String, fullName: String?) async throws -> AuthenticationSession {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        if shouldSimulateBackendFailure {
            throw AuthError.networkUnavailable
        }

        lock.lock()
        defer { lock.unlock() }

        let appleUser = AuthUser.createMock(
            email: "apple.user@privaterelay.appleid.com",
            displayName: fullName ?? "Người dùng Apple",
            isEmailVerified: true
        )
        let session = AuthenticationSession.authenticated(user: appleUser, accessToken: "mock_apple_token_\(UUID().uuidString)")
        activeSession = session
        return session
    }

    public func requestPasswordReset(email: String) async throws {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        if shouldSimulateBackendFailure {
            throw AuthError.networkUnavailable
        }

        lock.lock()
        defer { lock.unlock() }

        guard registeredUsers[email] != nil else {
            throw AuthError.userNotFound
        }
        // Explicitly labeled mock notice
        throw AuthError.mockModeNotice(
            message: "Chế độ thử nghiệm: Yêu cầu đặt lại mật khẩu cho '\(email)' đã được ghi nhận. Không có email thực tế nào được gửi đi."
        )
    }

    public func logout() async throws {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        lock.lock()
        defer { lock.unlock() }
        activeSession = .unauthenticated
    }

    public func deleteAccount() async throws {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        lock.lock()
        defer { lock.unlock() }

        if let currentEmail = activeSession.user?.email {
            registeredUsers.removeValue(forKey: currentEmail)
        }
        activeSession = .unauthenticated
    }

    public func continueAsGuest() async throws -> AuthenticationSession {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }
        lock.lock()
        defer { lock.unlock() }

        let guestUser = AuthUser.createGuest()
        let session = AuthenticationSession.guest(user: guestUser)
        activeSession = session
        return session
    }
}
