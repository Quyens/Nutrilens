//
//  AuthenticationSession.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Encapsulates the session state, active user, and security tokens.
//

import Foundation

public enum SessionStatus: String, Codable, Sendable {
    case unauthenticated
    case authenticated
    case guest
}

public struct AuthenticationSession: Equatable, Codable, Sendable {
    public let status: SessionStatus
    public let user: AuthUser?
    public let accessToken: String?
    public let refreshToken: String?
    public let expiresAt: Date?

    public init(
        status: SessionStatus,
        user: AuthUser?,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        expiresAt: Date? = nil
    ) {
        self.status = status
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    public var isAuthenticated: Bool {
        status == .authenticated && user != nil
    }

    public var isGuest: Bool {
        status == .guest && user?.isGuest == true
    }

    public static let unauthenticated = AuthenticationSession(
        status: .unauthenticated,
        user: nil,
        accessToken: nil,
        refreshToken: nil,
        expiresAt: nil
    )

    public static func authenticated(
        user: AuthUser,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        expiresAt: Date? = nil
    ) -> AuthenticationSession {
        AuthenticationSession(
            status: .authenticated,
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }

    public static func guest(user: AuthUser) -> AuthenticationSession {
        AuthenticationSession(
            status: .guest,
            user: user,
            accessToken: nil,
            refreshToken: nil,
            expiresAt: nil
        )
    }
}
