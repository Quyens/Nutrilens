//
//  MockUserDietaryProfileRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  In-memory mock repository for tests and SwiftUI previews.
//

import Foundation

public final class MockUserDietaryProfileRepository: UserDietaryProfileRepositoryProtocol, @unchecked Sendable {
    private var profile: UserDietaryProfile

    public init(initialProfile: UserDietaryProfile = UserDietaryProfile()) {
        self.profile = initialProfile
    }

    public func getDietaryProfile() async throws -> UserDietaryProfile {
        profile
    }

    public func saveDietaryProfile(_ profile: UserDietaryProfile) async throws {
        self.profile = profile
    }

    public func clearDietaryProfile() async throws {
        self.profile = UserDietaryProfile()
    }
}

