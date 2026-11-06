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
    public let authenticationRepository: AuthenticationRepositoryProtocol

    // Use Cases
    public let getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol
    public let logMealUseCase: LogMealUseCaseProtocol
    public let getMealHistoryUseCase: GetMealHistoryUseCaseProtocol
    public let recognizeFoodUseCase: RecognizeFoodUseCaseProtocol
    public let getNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol

    // Auth Use Cases
    public let getAuthSessionUseCase: GetAuthSessionUseCaseProtocol
    public let loginUseCase: LoginUseCaseProtocol
    public let registerUseCase: RegisterUseCaseProtocol
    public let signInWithAppleUseCase: SignInWithAppleUseCaseProtocol
    public let requestPasswordResetUseCase: RequestPasswordResetUseCaseProtocol
    public let continueAsGuestUseCase: ContinueAsGuestUseCaseProtocol
    public let logoutUseCase: LogoutUseCaseProtocol
    public let deleteAccountUseCase: DeleteAccountUseCaseProtocol
    public let isMockAuth: Bool

    public init(
        mealRepository: MealRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        foodRecognitionRepository: FoodRecognitionRepositoryProtocol,
        foodFavoritesRepository: FoodFavoritesRepositoryProtocol = FoodFavoritesRepository(),
        authenticationRepository: AuthenticationRepositoryProtocol = AuthenticationRepository(),
        isMockAuth: Bool = false
    ) {
        self.mealRepository = mealRepository
        self.userRepository = userRepository
        self.foodRecognitionRepository = foodRecognitionRepository
        self.foodFavoritesRepository = foodFavoritesRepository
        self.authenticationRepository = authenticationRepository
        self.isMockAuth = isMockAuth

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

        // Auth use cases
        self.getAuthSessionUseCase = GetAuthSessionUseCase(repository: authenticationRepository)
        self.loginUseCase = LoginUseCase(repository: authenticationRepository)
        self.registerUseCase = RegisterUseCase(repository: authenticationRepository)
        self.signInWithAppleUseCase = SignInWithAppleUseCase(repository: authenticationRepository)
        self.requestPasswordResetUseCase = RequestPasswordResetUseCase(repository: authenticationRepository)
        self.continueAsGuestUseCase = ContinueAsGuestUseCase(repository: authenticationRepository)
        self.logoutUseCase = LogoutUseCase(repository: authenticationRepository)
        self.deleteAccountUseCase = DeleteAccountUseCase(repository: authenticationRepository)
    }

    /// Factory method to build AuthViewModel for presentation sheets
    public func makeAuthViewModel(
        initialStep: AuthStep = .welcome,
        onAuthCompleted: (() -> Void)? = nil
    ) -> AuthViewModel {
        let vm = AuthViewModel(
            getAuthSessionUseCase: getAuthSessionUseCase,
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            signInWithAppleUseCase: signInWithAppleUseCase,
            requestPasswordResetUseCase: requestPasswordResetUseCase,
            continueAsGuestUseCase: continueAsGuestUseCase,
            logoutUseCase: logoutUseCase,
            deleteAccountUseCase: deleteAccountUseCase,
            isMockMode: isMockAuth,
            onAuthCompleted: onAuthCompleted
        )
        vm.currentStep = initialStep
        return vm
    }

    /// Standard production environment backed by SwiftData & Production CoreML Pipeline
    public static func live() -> AppEnvironment {
        let mealRepo = MealRepository()
        let userRepo = UserRepository()
        let foodRepo = FoodRecognitionRepository()
        let favoritesRepo = FoodFavoritesRepository()
        let authRepo = AuthenticationRepository()

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo,
            authenticationRepository: authRepo,
            isMockAuth: false
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
        let authRepo = MockAuthenticationRepository()

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo,
            authenticationRepository: authRepo,
            isMockAuth: true
        )
    }
}
