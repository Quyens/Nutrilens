//
//  AppEnvironment.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftData

@MainActor
public final class AppEnvironment: ObservableObject {
    // Repositories
    public let mealRepository: MealRepositoryProtocol
    public let userRepository: UserRepositoryProtocol
    public let foodRecognitionRepository: FoodRecognitionRepositoryProtocol
    public let foodFavoritesRepository: FoodFavoritesRepositoryProtocol

    // Use Cases
    public let getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol
    public let logMealUseCase: LogMealUseCaseProtocol
    public let getMealHistoryUseCase: GetMealHistoryUseCaseProtocol
    public let recognizeFoodUseCase: RecognizeFoodUseCaseProtocol
    public let getNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol

    public init(
        mealRepository: MealRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        foodRecognitionRepository: FoodRecognitionRepositoryProtocol,
        foodFavoritesRepository: FoodFavoritesRepositoryProtocol = FoodFavoritesRepository()
    ) {
        self.mealRepository = mealRepository
        self.userRepository = userRepository
        self.foodRecognitionRepository = foodRecognitionRepository
        self.foodFavoritesRepository = foodFavoritesRepository

        self.getDailySummaryUseCase = GetDailyNutritionSummaryUseCase(
            mealRepository: mealRepository,
            userRepository: userRepository
        )
        self.logMealUseCase = LogMealUseCase(mealRepository: mealRepository)
        self.getMealHistoryUseCase = GetMealHistoryUseCase(mealRepository: mealRepository)
        self.recognizeFoodUseCase = RecognizeFoodUseCase(repository: foodRecognitionRepository)
        self.getNutritionAnalyticsUseCase = GetNutritionAnalyticsUseCase(
            mealRepository: mealRepository,
            userRepository: userRepository
        )
    }

    /// Standard production environment backed by SwiftData & Production CoreML Pipeline
    public static func live() -> AppEnvironment {
        let mealRepo = MealRepository()
        let userRepo = UserRepository()
        let foodRepo = FoodRecognitionRepository()
        let favoritesRepo = FoodFavoritesRepository()

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo
        )
    }

    /// Mock environment for SwiftUI previews and UI tests
    public static func mock() -> AppEnvironment {
        let mealRepo = MockMealRepository()
        let userRepo = MockUserRepository()
        let foodRepo = MockFoodRecognitionRepository()
        let favoritesRepo = MockFoodFavoritesRepository(
            favoriteIds: ["dish_pho", "dish_banh_mi"],
            recentlyViewedIds: ["dish_com_tam", "dish_bun_cha"]
        )

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo
        )
    }
}
