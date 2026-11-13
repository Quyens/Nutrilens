//
//  UserDietaryProfileRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Persistent local storage for UserDietaryProfile using UserDefaults.
//

import Foundation

public final class UserDietaryProfileRepository: UserDietaryProfileRepositoryProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let storageKey: String

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "com.nutrilens.userDietaryProfile"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func getDietaryProfile() async throws -> UserDietaryProfile {
        guard let data = userDefaults.data(forKey: storageKey) else {
            // Default baseline profile
            return UserDietaryProfile()
        }
        do {
            let profile = try JSONDecoder().decode(UserDietaryProfile.self, from: data)
            return profile
        } catch {
            AppLogger.data.warning("Failed to decode UserDietaryProfile, returning default: \(error.localizedDescription)")
            return UserDietaryProfile()
        }
    }

    public func saveDietaryProfile(_ profile: UserDietaryProfile) async throws {
        do {
            var updated = profile
            updated.updatedAt = Date()
            let data = try JSONEncoder().encode(updated)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            throw AppError.dataPersistenceFailed("Failed to encode UserDietaryProfile: \(error.localizedDescription)")
        }
    }

    public func clearDietaryProfile() async throws {
        userDefaults.removeObject(forKey: storageKey)
    }
}

