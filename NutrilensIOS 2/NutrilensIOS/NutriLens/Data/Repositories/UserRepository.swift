//
//  UserRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public final class UserRepository: UserRepositoryProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key = "com.nutrilens.userProfile"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func getUserProfile() async throws -> UserProfile {
        guard let data = userDefaults.data(forKey: key) else {
            // Return default initial profile
            return UserProfile()
        }
        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            return UserProfile()
        }
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: key)
        } catch {
            throw AppError.dataPersistenceFailed("Failed to encode user profile: \(error.localizedDescription)")
        }
    }
}

public final class MockUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    private var profile: UserProfile

    public init(initialProfile: UserProfile = UserProfile(name: "Alex Nguyen", goal: .balancedNutrition, isOnboardingCompleted: true)) {
        self.profile = initialProfile
    }

    public func getUserProfile() async throws -> UserProfile {
        profile
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        self.profile = profile
    }
}
