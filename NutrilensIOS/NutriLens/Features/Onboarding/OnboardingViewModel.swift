//
//  OnboardingViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class OnboardingViewModel: ObservableObject {
    @Published public var currentStep: Int = 0
    @Published public var selectedGoal: DietaryGoal = .balancedNutrition
    @Published public var dailyCalorieTarget: Double = 2000
    @Published public var userName: String = ""
    @Published public var isSaving: Bool = false

    private let userRepository: UserRepositoryProtocol
    private let onComplete: () -> Void

    public init(
        userRepository: UserRepositoryProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.userRepository = userRepository
        self.onComplete = onComplete
    }

    public func completeOnboarding() {
        Task {
            isSaving = true
            let profile = UserProfile(
                name: userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "NutriUser" : userName,
                goal: selectedGoal,
                dailyCalorieTarget: dailyCalorieTarget,
                dailyProteinTargetGrams: (dailyCalorieTarget * 0.25) / 4.0,
                dailyCarbTargetGrams: (dailyCalorieTarget * 0.50) / 4.0,
                dailyFatTargetGrams: (dailyCalorieTarget * 0.25) / 9.0,
                isOnboardingCompleted: true
            )
            try? await userRepository.saveUserProfile(profile)
            isSaving = false
            onComplete()
        }
    }
}
