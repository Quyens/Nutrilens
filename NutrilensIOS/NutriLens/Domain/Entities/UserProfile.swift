//
//  UserProfile.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public enum DietaryGoal: String, CaseIterable, Codable, Sendable {
    case maintainWeight = "Maintain Weight"
    case loseWeight = "Weight Loss"
    case gainMuscle = "Muscle Gain"
    case balancedNutrition = "Healthy Eating"
}

public struct UserProfile: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var goal: DietaryGoal
    public var dailyCalorieTarget: Double
    public var dailyProteinTargetGrams: Double
    public var dailyCarbTargetGrams: Double
    public var dailyFatTargetGrams: Double
    public var isOnboardingCompleted: Bool

    public init(
        id: UUID = UUID(),
        name: String = "User",
        goal: DietaryGoal = .balancedNutrition,
        dailyCalorieTarget: Double = 2000,
        dailyProteinTargetGrams: Double = 130,
        dailyCarbTargetGrams: Double = 220,
        dailyFatTargetGrams: Double = 65,
        isOnboardingCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.goal = goal
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dailyProteinTargetGrams = dailyProteinTargetGrams
        self.dailyCarbTargetGrams = dailyCarbTargetGrams
        self.dailyFatTargetGrams = dailyFatTargetGrams
        self.isOnboardingCompleted = isOnboardingCompleted
    }
}
