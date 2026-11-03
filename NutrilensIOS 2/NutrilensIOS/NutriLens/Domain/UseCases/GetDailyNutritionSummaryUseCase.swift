//
//  GetDailyNutritionSummaryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol GetDailyNutritionSummaryUseCaseProtocol: Sendable {
    func execute(for date: Date) async throws -> NutritionSummary
}

public final class GetDailyNutritionSummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    public init(mealRepository: MealRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.mealRepository = mealRepository
        self.userRepository = userRepository
    }

    public func execute(for date: Date) async throws -> NutritionSummary {
        let meals = try await mealRepository.fetchMeals(for: date)
        let profile = (try? await userRepository.getUserProfile()) ?? UserProfile()

        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = meals.reduce(0) { $0 + $1.totalProteinGrams }
        let totalCarbs = meals.reduce(0) { $0 + $1.totalCarbGrams }
        let totalFat = meals.reduce(0) { $0 + $1.totalFatGrams }
        let totalFiber = meals.reduce(0) { $0 + $1.totalFiberGrams }

        return NutritionSummary(
            date: date,
            consumedCalories: totalCalories,
            targetCalories: profile.dailyCalorieTarget,
            consumedProteinGrams: totalProtein,
            targetProteinGrams: profile.dailyProteinTargetGrams,
            consumedCarbGrams: totalCarbs,
            targetCarbGrams: profile.dailyCarbTargetGrams,
            consumedFatGrams: totalFat,
            targetFatGrams: profile.dailyFatTargetGrams,
            consumedFiberGrams: totalFiber,
            targetFiberGrams: 30
        )
    }
}
