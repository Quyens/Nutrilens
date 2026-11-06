//
//  AuthenticationRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Production implementation managing secure Keychain session storage with backend-deferred architecture.
//

import Foundation

public final class AuthenticationRepository: AuthenticationRepositoryProtocol, @unchecked Sendable {
    private let keychainService: KeychainServiceProtocol
    private let sessionKey = "com.nutrilens.auth.session"

    public init(keychainService: KeychainServiceProtocol = KeychainService.shared) {
        self.keychainService = keychainService
    }

    public func getCurrentSession() async throws -> AuthenticationSession {
        guard let data = try keychainService.read(key: sessionKey) else {
            return .unauthenticated
        }
        do {
            return try JSONDecoder().decode(AuthenticationSession.self, from: data)
        } catch {
            // If session data is corrupted, wipe and return unauthenticated
            try? keychainService.delete(key: sessionKey)
            return .unauthenticated
        }
    }

    public func register(email: String, password: String, displayName: String) async throws -> AuthenticationSession {
        // Backend (Supabase) is intentionally deferred. Real passwords are never stored locally.
        throw AuthError.backendUnavailable(
            message: "Dịch vụ tài khoản trực tuyến chưa được cấu hình. Bạn có thể sử dụng Chế độ Khách (Guest) để trải nghiệm đầy đủ các tính năng của NutriLens mà không cần tài khoản."
        )
    }

    public func login(email: String, password: String) async throws -> AuthenticationSession {
        // Backend (Supabase) is intentionally deferred.
        throw AuthError.backendUnavailable(
            message: "Dịch vụ đăng nhập trực tuyến chưa được kích hoạt. Bạn có thể sử dụng Chế độ Khách (Guest) để trải nghiệm đầy đủ các tính năng của NutriLens mà không cần tài khoản."
        )
    }

    public func signInWithApple(idToken: String, nonce: String, fullName: String?) async throws -> AuthenticationSession {
        // Apple Sign-In exchange requires backend token verification
        throw AuthError.backendUnavailable(
            message: "Đăng nhập bằng Apple ID cần xác thực qua máy chủ trực tuyến. Vui lòng sử dụng Chế độ Khách."
        )
    }

    public func requestPasswordReset(email: String) async throws {
        throw AuthError.backendUnavailable(
            message: "Hệ thống email chưa được kết nối máy chủ. Vui lòng thử lại sau khi dịch vụ backend được phát hành."
        )
    }

    public func logout() async throws {
        try keychainService.delete(key: sessionKey)
    }

    public func deleteAccount() async throws {
        let current = try await getCurrentSession()
        if current.isGuest {
            try await logout()
            return
        }
        throw AuthError.backendUnavailable(
            message: "Không thể xóa tài khoản trực tuyến khi chưa kết nối máy chủ."
        )
    }

    public func continueAsGuest() async throws -> AuthenticationSession {
        // Check if an existing guest user ID is already persisted in Keychain
        var guestUser: AuthUser
        if let existing = try? await getCurrentSession(), existing.isGuest, let user = existing.user {
            guestUser = user
            guestUser.lastLoginAt = Date()
        } else {
            guestUser = AuthUser.createGuest()
        }

        let session = AuthenticationSession.guest(user: guestUser)
        let data = try JSONEncoder().encode(session)
        try keychainService.save(key: sessionKey, data: data)
        return session
    }
}
