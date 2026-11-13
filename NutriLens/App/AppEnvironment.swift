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
    public let hydrationRepository: HydrationRepositoryProtocol
    public let customFoodRepository: CustomFoodRepositoryProtocol
    public let recipeRepository: RecipeRepositoryProtocol
    public let mealPlanRepository: MealPlanRepositoryProtocol
    public let userDietaryProfileRepository: UserDietaryProfileRepositoryProtocol
    public let packagedFoodRepository: PackagedFoodRepositoryProtocol

    // Services
    public let unitFormattingService: UnitFormattingServiceProtocol
    public let hapticFeedbackService: HapticFeedbackServiceProtocol

    // Use Cases
    public let getDailySummaryUseCase: GetDailyNutritionSummaryUseCaseProtocol
    public let logMealUseCase: LogMealUseCaseProtocol
    public let getMealHistoryUseCase: GetMealHistoryUseCaseProtocol
    public let recognizeFoodUseCase: RecognizeFoodUseCaseProtocol
    public let getNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol

    // Hydration Use Cases
    public let addHydrationUseCase: AddHydrationUseCaseProtocol
    public let getDailyHydrationUseCase: GetDailyHydrationUseCaseProtocol
    public let getHydrationHistoryUseCase: GetHydrationHistoryUseCaseProtocol
    public let deleteHydrationUseCase: DeleteHydrationUseCaseProtocol

    // Phase 03: Custom Foods & Recipes Use Cases
    public let getCustomFoodsUseCase: GetCustomFoodsUseCaseProtocol
    public let saveCustomFoodUseCase: SaveCustomFoodUseCaseProtocol
    public let deleteCustomFoodUseCase: DeleteCustomFoodUseCaseProtocol
    public let getRecipesUseCase: GetRecipesUseCaseProtocol
    public let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    public let deleteRecipeUseCase: DeleteRecipeUseCaseProtocol
    public let calculateRecipeNutritionUseCase: CalculateRecipeNutritionUseCaseProtocol

    // Phase 04: Weekly Meal Planner Use Cases
    public let getWeeklyMealPlanUseCase: GetWeeklyMealPlanUseCaseProtocol
    public let savePlannedMealUseCase: SavePlannedMealUseCaseProtocol
    public let deletePlannedMealUseCase: DeletePlannedMealUseCaseProtocol
    public let markPlannedMealStatusUseCase: MarkPlannedMealStatusUseCaseProtocol
    public let copyDayPlanUseCase: CopyDayPlanUseCaseProtocol
    public let logPlannedMealToDiaryUseCase: LogPlannedMealToDiaryUseCaseProtocol

    // Phase 05: Smart Meal Suggestions Use Cases
    public let smartMealSuggestionsUseCase: SmartMealSuggestionsUseCaseProtocol

    // Phase 06: Barcode Scanner & Packaged Food Use Cases
    public let lookupBarcodeUseCase: LookupBarcodeUseCase
    public let savePackagedFoodUseCase: SavePackagedFoodUseCase
    public let deletePackagedFoodUseCase: DeletePackagedFoodUseCase
    public let getPackagedFoodsUseCase: GetPackagedFoodsUseCase
    public let logPackagedFoodToDiaryUseCase: LogPackagedFoodToDiaryUseCase

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
        hydrationRepository: HydrationRepositoryProtocol = HydrationRepository(),
        customFoodRepository: CustomFoodRepositoryProtocol = CustomFoodRepository(),
        recipeRepository: RecipeRepositoryProtocol = RecipeRepository(),
        mealPlanRepository: MealPlanRepositoryProtocol = MealPlanRepository(),
        userDietaryProfileRepository: UserDietaryProfileRepositoryProtocol = UserDietaryProfileRepository(),
        packagedFoodRepository: PackagedFoodRepositoryProtocol = PackagedFoodRepository(),
        unitFormattingService: UnitFormattingServiceProtocol = UnitFormattingService.shared,
        hapticFeedbackService: HapticFeedbackServiceProtocol = HapticFeedbackService.shared,
        isMockAuth: Bool = false
    ) {
        self.mealRepository = mealRepository
        self.userRepository = userRepository
        self.foodRecognitionRepository = foodRecognitionRepository
        self.foodFavoritesRepository = foodFavoritesRepository
        self.authenticationRepository = authenticationRepository
        self.hydrationRepository = hydrationRepository
        self.customFoodRepository = customFoodRepository
        self.recipeRepository = recipeRepository
        self.mealPlanRepository = mealPlanRepository
        self.userDietaryProfileRepository = userDietaryProfileRepository
        self.packagedFoodRepository = packagedFoodRepository
        self.unitFormattingService = unitFormattingService
        self.hapticFeedbackService = hapticFeedbackService
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

        // Hydration use cases
        self.addHydrationUseCase = AddHydrationUseCase(repository: hydrationRepository)
        self.getDailyHydrationUseCase = GetDailyHydrationUseCase(repository: hydrationRepository)
        self.getHydrationHistoryUseCase = GetHydrationHistoryUseCase(repository: hydrationRepository)
        self.deleteHydrationUseCase = DeleteHydrationUseCase(repository: hydrationRepository)

        // Phase 03: Custom Foods & Recipes use cases
        self.getCustomFoodsUseCase = GetCustomFoodsUseCase(repository: customFoodRepository)
        self.saveCustomFoodUseCase = SaveCustomFoodUseCase(repository: customFoodRepository)
        self.deleteCustomFoodUseCase = DeleteCustomFoodUseCase(repository: customFoodRepository)
        self.getRecipesUseCase = GetRecipesUseCase(repository: recipeRepository)
        self.saveRecipeUseCase = SaveRecipeUseCase(repository: recipeRepository)
        self.deleteRecipeUseCase = DeleteRecipeUseCase(repository: recipeRepository)
        self.calculateRecipeNutritionUseCase = CalculateRecipeNutritionUseCase()

        // Phase 04: Weekly Meal Planner use cases
        self.getWeeklyMealPlanUseCase = GetWeeklyMealPlanUseCase(repository: mealPlanRepository)
        self.savePlannedMealUseCase = SavePlannedMealUseCase(repository: mealPlanRepository)
        self.deletePlannedMealUseCase = DeletePlannedMealUseCase(repository: mealPlanRepository)
        self.markPlannedMealStatusUseCase = MarkPlannedMealStatusUseCase(repository: mealPlanRepository)
        self.copyDayPlanUseCase = CopyDayPlanUseCase(repository: mealPlanRepository)
        self.logPlannedMealToDiaryUseCase = LogPlannedMealToDiaryUseCase(
            mealPlanRepository: mealPlanRepository,
            mealRepository: mealRepository
        )

        // Phase 05: Smart Meal Suggestions
        self.smartMealSuggestionsUseCase = SmartMealSuggestionsUseCase(
            userDietaryProfileRepository: userDietaryProfileRepository,
            foodFavoritesRepository: foodFavoritesRepository,
            customFoodRepository: customFoodRepository,
            recipeRepository: recipeRepository,
            mealPlanRepository: mealPlanRepository,
            mealRepository: mealRepository
        )

        // Phase 06: Barcode Scanner & Packaged Food Use Cases
        self.lookupBarcodeUseCase = LookupBarcodeUseCase(repository: packagedFoodRepository)
        self.savePackagedFoodUseCase = SavePackagedFoodUseCase(repository: packagedFoodRepository)
        self.deletePackagedFoodUseCase = DeletePackagedFoodUseCase(repository: packagedFoodRepository)
        self.getPackagedFoodsUseCase = GetPackagedFoodsUseCase(repository: packagedFoodRepository)
        self.logPackagedFoodToDiaryUseCase = LogPackagedFoodToDiaryUseCase(mealRepository: mealRepository)

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

    /// Factory method to build SmartSuggestionsViewModel
    public func makeSmartSuggestionsViewModel(
        initialCategory: PlannedMealCategory? = nil,
        initialDate: Date = Date()
    ) -> SmartSuggestionsViewModel {
        SmartSuggestionsViewModel(
            useCase: smartMealSuggestionsUseCase,
            hapticService: hapticFeedbackService,
            initialCategory: initialCategory,
            initialDate: initialDate
        )
    }

    /// Factory method to build BarcodeScannerViewModel
    public func makeBarcodeScannerViewModel(
        captureService: BarcodeCaptureServiceProtocol? = nil
    ) -> BarcodeScannerViewModel {
        let service = captureService ?? BarcodeCaptureService()
        return BarcodeScannerViewModel(
            lookupUseCase: lookupBarcodeUseCase,
            saveUseCase: savePackagedFoodUseCase,
            deleteUseCase: deletePackagedFoodUseCase,
            getFoodsUseCase: getPackagedFoodsUseCase,
            logDiaryUseCase: logPackagedFoodToDiaryUseCase,
            userProfileRepository: userDietaryProfileRepository,
            captureService: service
        )
    }

    /// Standard production environment backed by SwiftData & Production CoreML Pipeline
    public static func live() -> AppEnvironment {
        let mealRepo = MealRepository()
        let userRepo = UserRepository()
        let foodRepo = FoodRecognitionRepository()
        let favoritesRepo = FoodFavoritesRepository()
        let authRepo = AuthenticationRepository()
        let hydrationRepo = HydrationRepository()
        let customFoodRepo = CustomFoodRepository()
        let recipeRepo = RecipeRepository()
        let mealPlanRepo = MealPlanRepository()
        let dietaryRepo = UserDietaryProfileRepository()
        let packagedFoodRepo = PackagedFoodRepository()

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo,
            authenticationRepository: authRepo,
            hydrationRepository: hydrationRepo,
            customFoodRepository: customFoodRepo,
            recipeRepository: recipeRepo,
            mealPlanRepository: mealPlanRepo,
            userDietaryProfileRepository: dietaryRepo,
            packagedFoodRepository: packagedFoodRepo,
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
        let hydrationRepo = MockHydrationRepository(
            initialRecords: [
                HydrationRecord(amountLiters: 0.5, notes: "Buổi sáng"),
                HydrationRecord(amountLiters: 0.5, notes: "Buổi trưa")
            ]
        )
        let customFoodRepo = MockCustomFoodRepository()
        let recipeRepo = MockRecipeRepository()
        let mealPlanRepo = MockMealPlanRepository()
        let dietaryRepo = MockUserDietaryProfileRepository()
        let packagedFoodRepo = MockPackagedFoodRepository()

        return AppEnvironment(
            mealRepository: mealRepo,
            userRepository: userRepo,
            foodRecognitionRepository: foodRepo,
            foodFavoritesRepository: favoritesRepo,
            authenticationRepository: authRepo,
            hydrationRepository: hydrationRepo,
            customFoodRepository: customFoodRepo,
            recipeRepository: recipeRepo,
            mealPlanRepository: mealPlanRepo,
            userDietaryProfileRepository: dietaryRepo,
            packagedFoodRepository: packagedFoodRepo,
            isMockAuth: true
        )
    }
}
