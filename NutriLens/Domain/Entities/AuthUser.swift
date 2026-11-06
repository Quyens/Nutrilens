//
//  AuthUser.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents an authenticated user or guest user within the domain.
//

import Foundation

public struct AuthUser: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let email: String
    public var displayName: String
    public var isEmailVerified: Bool
    public let isGuest: Bool
    public let isMockAccount: Bool
    public let createdAt: Date
    public var lastLoginAt: Date?

    public init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        isEmailVerified: Bool = false,
        isGuest: Bool = false,
        isMockAccount: Bool = false,
        createdAt: Date = Date(),
        lastLoginAt: Date? = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isEmailVerified = isEmailVerified
        self.isGuest = isGuest
        self.isMockAccount = isMockAccount
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }

    /// Factory for creating an anonymous local guest user
    public static func createGuest(id: UUID = UUID()) -> AuthUser {
        AuthUser(
            id: id,
            email: "guest@nutrilens.local",
            displayName: "Khách NutriLens",
            isEmailVerified: false,
            isGuest: true,
            isMockAccount: false,
            createdAt: Date(),
            lastLoginAt: Date()
        )
    }

    /// Factory for creating a development mock user with explicit labeling
    public static func createMock(
        email: String = "demo@nutrilens.vn",
        displayName: String = "Người Dùng Thử Nghiệm",
        isEmailVerified: Bool = true
    ) -> AuthUser {
        AuthUser(
            id: UUID(),
            email: email,
            displayName: displayName,
            isEmailVerified: isEmailVerified,
            isGuest: false,
            isMockAccount: true,
            createdAt: Date(),
            lastLoginAt: Date()
        )
    }
}
