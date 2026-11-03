//
//  UserRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol UserRepositoryProtocol: Sendable {
    func getUserProfile() async throws -> UserProfile
    func saveUserProfile(_ profile: UserProfile) async throws
}
