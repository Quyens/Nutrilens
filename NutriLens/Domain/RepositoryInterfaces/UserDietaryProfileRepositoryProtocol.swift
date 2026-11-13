//
//  UserDietaryProfileRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Repository contract for managing user dietary habits, allergens, and excluded ingredients.
//

import Foundation

public protocol UserDietaryProfileRepositoryProtocol: Sendable {
    func getDietaryProfile() async throws -> UserDietaryProfile
    func saveDietaryProfile(_ profile: UserDietaryProfile) async throws
    func clearDietaryProfile() async throws
}

