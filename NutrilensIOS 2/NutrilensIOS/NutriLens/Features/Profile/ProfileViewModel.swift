//
//  ProfileViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class ProfileViewModel: ObservableObject {
    @Published public private(set) var profile: UserProfile = UserProfile()
    @Published public private(set) var isLoading: Bool = false
    @Published public var isEditing: Bool = false

    private let userRepository: UserRepositoryProtocol

    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    public func loadProfile() async {
        isLoading = true
        if let loaded = try? await userRepository.getUserProfile() {
            self.profile = loaded
        }
        isLoading = false
    }

    public func updateProfile(name: String, goal: DietaryGoal, calories: Double) async {
        var updated = profile
        updated.name = name
        updated.goal = goal
        updated.dailyCalorieTarget = calories
        updated.dailyProteinTargetGrams = (calories * 0.25) / 4.0
        updated.dailyCarbTargetGrams = (calories * 0.50) / 4.0
        updated.dailyFatTargetGrams = (calories * 0.25) / 9.0

        try? await userRepository.saveUserProfile(updated)
        self.profile = updated
        self.isEditing = false
    }
}
