//
//  HomeViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public private(set) var state: AsyncState<NutritionSummary> = .idle
    @Published public private(set) var todaysMeals: [MealRecord] = []
    @Published public private(set) var userProfile: UserProfile = UserProfile()

    private let getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol
    private let mealRepository: MealRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    public init(
        getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol,
        mealRepository: MealRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.getDailySummaryUseCase = getDailySummaryUseCase
        self.mealRepository = mealRepository
        self.userRepository = userRepository
    }

    public func loadDashboard() async {
        state = .loading
        do {
            async let summaryTask = getDailySummaryUseCase.execute(for: Date())
            async let mealsTask = mealRepository.fetchMeals(for: Date())
            async let profileTask = userRepository.getUserProfile()

            let (summary, meals, profile) = try await (summaryTask, mealsTask, profileTask)
            self.todaysMeals = meals
            self.userProfile = profile
            self.state = .success(summary)
        } catch let err as AppError {
            self.state = .failure(err)
        } catch {
            self.state = .failure(.unknown(error.localizedDescription))
        }
    }
}
