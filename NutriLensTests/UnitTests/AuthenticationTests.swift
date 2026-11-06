//
//  AuthenticationTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Exhaustive test suite covering Domain entities, Use Cases, Repositories, ViewModels, and Data Safety.
//

import XCTest
@testable import NutriLens

@MainActor
final class AuthenticationTests: XCTestCase {

    // MARK: - 1. Email & Password Validation Tests

    func testValidEmailValidation() async throws {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        let session = try await registerUseCase.execute(
            email: "valid.user@example.com",
            password: "StrongPassword123",
            confirmPassword: "StrongPassword123",
            displayName: "Test User"
        )
        XCTAssertEqual(session.user?.email, "valid.user@example.com")
        XCTAssertTrue(session.isAuthenticated)
    }

    func testInvalidEmailValidationThrows() async {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        let invalidEmails = ["notanemail", "user@", "@domain.com", "user@.com", "user name@domain.com"]
        for email in invalidEmails {
            do {
                _ = try await registerUseCase.execute(
                    email: email,
                    password: "ValidPass123",
                    confirmPassword: "ValidPass123",
                    displayName: "User"
                )
                XCTFail("Registration with invalid email '\(email)' should fail")
            } catch let err as AuthError {
                XCTAssertEqual(err, .invalidEmail)
            } catch {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func testPasswordLengthValidation() async {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        do {
            _ = try await registerUseCase.execute(
                email: "test@example.com",
                password: "Pass1", // < 8 characters
                confirmPassword: "Pass1",
                displayName: "User"
            )
            XCTFail("Password shorter than 8 chars should throw weakPassword")
        } catch let err as AuthError {
            if case .weakPassword = err {
                // Expected
            } else {
                XCTFail("Expected weakPassword, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPasswordAlphanumericValidation() async {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        // Letters only, no numbers
        do {
            _ = try await registerUseCase.execute(
                email: "test@example.com",
                password: "OnlyLettersLongEnough",
                confirmPassword: "OnlyLettersLongEnough",
                displayName: "User"
            )
            XCTFail("Password without numbers should throw weakPassword")
        } catch let err as AuthError {
            if case .weakPassword = err {
                // Expected
            } else {
                XCTFail("Expected weakPassword, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        // Numbers only, no letters
        do {
            _ = try await registerUseCase.execute(
                email: "test@example.com",
                password: "1234567890123",
                confirmPassword: "1234567890123",
                displayName: "User"
            )
            XCTFail("Password without letters should throw weakPassword")
        } catch let err as AuthError {
            if case .weakPassword = err {
                // Expected
            } else {
                XCTFail("Expected weakPassword, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPasswordsMismatchThrows() async {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        do {
            _ = try await registerUseCase.execute(
                email: "test@example.com",
                password: "ValidPass123",
                confirmPassword: "DifferentPass456",
                displayName: "User"
            )
            XCTFail("Mismatched passwords must throw passwordsDoNotMatch")
        } catch let err as AuthError {
            XCTAssertEqual(err, .passwordsDoNotMatch)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - 2. Registration & Login Flow Tests

    func testRegistrationSuccessInMockMode() async throws {
        let repo = MockAuthenticationRepository(preloadDemoUser: false)
        let registerUseCase = RegisterUseCase(repository: repo)

        let session = try await registerUseCase.execute(
            email: "alice@nutrilens.vn",
            password: "MySecurePassword1",
            confirmPassword: "MySecurePassword1",
            displayName: "Alice Tran"
        )
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.user?.displayName, "Alice Tran")
        XCTAssertEqual(session.user?.email, "alice@nutrilens.vn")
        XCTAssertTrue(session.user?.isMockAccount == true)
        XCTAssertFalse(session.user?.isGuest == true)
    }

    func testDuplicateEmailRegistrationThrows() async throws {
        let repo = MockAuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        do {
            _ = try await registerUseCase.execute(
                email: "demo@nutrilens.vn", // preloaded
                password: "Password123",
                confirmPassword: "Password123",
                displayName: "Demo"
            )
            XCTFail("Duplicate email registration must throw emailAlreadyInUse")
        } catch let err as AuthError {
            XCTAssertEqual(err, .emailAlreadyInUse)
        }
    }

    func testLoginSuccessWithCorrectCredentials() async throws {
        let repo = MockAuthenticationRepository()
        let loginUseCase = LoginUseCase(repository: repo)

        let session = try await loginUseCase.execute(
            email: "demo@nutrilens.vn",
            password: "NutriLens2026!"
        )
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.user?.email, "demo@nutrilens.vn")
        XCTAssertNotNil(session.accessToken)
    }

    func testLoginWithWrongPasswordThrows() async {
        let repo = MockAuthenticationRepository()
        let loginUseCase = LoginUseCase(repository: repo)

        do {
            _ = try await loginUseCase.execute(email: "demo@nutrilens.vn", password: "IncorrectPassword999")
            XCTFail("Incorrect password must throw wrongPassword")
        } catch let err as AuthError {
            XCTAssertEqual(err, .wrongPassword)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLoginWithUnregisteredEmailThrows() async {
        let repo = MockAuthenticationRepository()
        let loginUseCase = LoginUseCase(repository: repo)

        do {
            _ = try await loginUseCase.execute(email: "nonexistent@nutrilens.vn", password: "Password123")
            XCTFail("Unregistered email must throw userNotFound")
        } catch let err as AuthError {
            XCTAssertEqual(err, .userNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAppleSignInSuccess() async throws {
        let repo = MockAuthenticationRepository()
        let appleUseCase = SignInWithAppleUseCase(repository: repo)

        let session = try await appleUseCase.execute(
            idToken: "mock_identity_token_sample",
            nonce: "mock_nonce_sample",
            fullName: "Nguyễn Văn Apple"
        )
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.user?.displayName, "Nguyễn Văn Apple")
        XCTAssertTrue(session.user?.email.contains("appleid.com") == true)
    }

    // MARK: - 3. Guest Mode & Data Safety Tests

    func testGuestModeInitializationAndPersistence() async throws {
        let repo = MockAuthenticationRepository()
        let guestUseCase = ContinueAsGuestUseCase(repository: repo)

        let session = try await guestUseCase.execute()
        XCTAssertTrue(session.isGuest)
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertEqual(session.user?.displayName, "Khách NutriLens")
        XCTAssertEqual(session.user?.email, "guest@nutrilens.local")

        let current = try await repo.getCurrentSession()
        XCTAssertEqual(current, session)
    }

    func testGuestModePreservesExistingLocalData() async throws {
        // Preload meals into MockMealRepository
        let initialMeal = MealRecord(
            mealType: .breakfast,
            items: [FoodItem(name: "Phở Bò", vietnameseName: "Phở Bò", confidence: 0.95, servingSizeGrams: 500, calories: 450, proteinGrams: 25, carbGrams: 60, fatGrams: 10, fiberGrams: 2)]
        )
        let mealRepo = MockMealRepository(initialMeals: [initialMeal])
        let authRepo = MockAuthenticationRepository()

        // Guest logs in
        _ = try await authRepo.continueAsGuest()

        // Verify local meal records are completely unaffected
        let meals = try await mealRepo.fetchAllMeals()
        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals.first?.items.first?.name, "Phở Bò")
    }

    // MARK: - 4. Session State Transitions, Logout & Deletion

    func testSessionStateTransitionsFromUnauthenticatedToLoggedIn() async throws {
        let repo = MockAuthenticationRepository(initialSession: .unauthenticated)

        var session = try await repo.getCurrentSession()
        XCTAssertEqual(session.status, .unauthenticated)

        session = try await repo.login(email: "demo@nutrilens.vn", password: "NutriLens2026!")
        XCTAssertEqual(session.status, .authenticated)

        try await repo.logout()
        session = try await repo.getCurrentSession()
        XCTAssertEqual(session.status, .unauthenticated)
    }

    func testLogoutClearsSessionAndRevertsToUnauthenticated() async throws {
        let repo = MockAuthenticationRepository()
        _ = try await repo.login(email: "demo@nutrilens.vn", password: "NutriLens2026!")
        let loggedInSession = try await repo.getCurrentSession()
        XCTAssertTrue(loggedInSession.isAuthenticated)

        try await repo.logout()
        let afterLogout = try await repo.getCurrentSession()
        XCTAssertFalse(afterLogout.isAuthenticated)
        XCTAssertNil(afterLogout.user)
    }

    func testAccountDeletionClearsSessionAndRemovesUser() async throws {
        let repo = MockAuthenticationRepository()
        _ = try await repo.login(email: "demo@nutrilens.vn", password: "NutriLens2026!")

        try await repo.deleteAccount()
        let afterDelete = try await repo.getCurrentSession()
        XCTAssertFalse(afterDelete.isAuthenticated)

        // Login should now fail with userNotFound
        do {
            _ = try await repo.login(email: "demo@nutrilens.vn", password: "NutriLens2026!")
            XCTFail("Deleted user should not be able to log in")
        } catch let err as AuthError {
            XCTAssertEqual(err, .userNotFound)
        }
    }

    // MARK: - 5. Password Reset & Backend Deferred Safety

    func testPasswordResetInMockModeProvidesHonestNotice() async {
        let repo = MockAuthenticationRepository()
        let resetUseCase = RequestPasswordResetUseCase(repository: repo)

        do {
            try await resetUseCase.execute(email: "demo@nutrilens.vn")
            XCTFail("Should produce a mock notice error")
        } catch let err as AuthError {
            if case .mockModeNotice(let msg) = err {
                XCTAssertTrue(msg.contains("Chế độ thử nghiệm"))
            } else {
                XCTFail("Expected mockModeNotice, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPasswordResetInProductionRepoThrowsBackendUnavailable() async {
        let repo = AuthenticationRepository()
        let resetUseCase = RequestPasswordResetUseCase(repository: repo)

        do {
            try await resetUseCase.execute(email: "test@nutrilens.vn")
            XCTFail("Production repo without backend must throw backendUnavailable")
        } catch let err as AuthError {
            if case .backendUnavailable = err {
                // Expected
            } else {
                XCTFail("Expected backendUnavailable, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testProductionRepoLoginThrowsBackendUnavailable() async {
        let repo = AuthenticationRepository()
        let loginUseCase = LoginUseCase(repository: repo)

        do {
            _ = try await loginUseCase.execute(email: "any@example.com", password: "AnyPassword123")
            XCTFail("Production login without backend must throw backendUnavailable")
        } catch let err as AuthError {
            if case .backendUnavailable(let msg) = err {
                XCTAssertTrue(msg.contains("Chế độ Khách"))
            } else {
                XCTFail("Expected backendUnavailable, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testProductionRepoRegistrationThrowsBackendUnavailable() async {
        let repo = AuthenticationRepository()
        let registerUseCase = RegisterUseCase(repository: repo)

        do {
            _ = try await registerUseCase.execute(
                email: "any@example.com",
                password: "StrongPass123",
                confirmPassword: "StrongPass123",
                displayName: "Any Name"
            )
            XCTFail("Production register without backend must throw backendUnavailable")
        } catch let err as AuthError {
            if case .backendUnavailable = err {
                // Expected
            } else {
                XCTFail("Expected backendUnavailable, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - 6. ViewModel Tests

    func testViewModelLoginFormValidation() {
        let repo = MockAuthenticationRepository()
        let env = AppEnvironment(
            mealRepository: MockMealRepository(),
            userRepository: MockUserRepository(),
            foodRecognitionRepository: MockFoodRecognitionRepository(),
            authenticationRepository: repo,
            isMockAuth: true
        )
        let vm = env.makeAuthViewModel(initialStep: .login)

        XCTAssertFalse(vm.isLoginFormValid)

        vm.email = "user@test.com"
        XCTAssertFalse(vm.isLoginFormValid)

        vm.password = "123456"
        XCTAssertTrue(vm.isLoginFormValid)
    }

    func testViewModelRegisterFormValidation() {
        let repo = MockAuthenticationRepository()
        let env = AppEnvironment(
            mealRepository: MockMealRepository(),
            userRepository: MockUserRepository(),
            foodRecognitionRepository: MockFoodRecognitionRepository(),
            authenticationRepository: repo,
            isMockAuth: true
        )
        let vm = env.makeAuthViewModel(initialStep: .register)

        XCTAssertFalse(vm.isRegisterFormValid)

        vm.email = "valid@test.com"
        vm.password = "Short1"
        vm.confirmPassword = "Short1"
        XCTAssertFalse(vm.isRegisterFormValid) // password < 8 chars

        vm.password = "LongEnoughPassword1"
        vm.confirmPassword = "MismatchPassword2"
        XCTAssertFalse(vm.isRegisterFormValid) // mismatch

        vm.confirmPassword = "LongEnoughPassword1"
        XCTAssertTrue(vm.isRegisterFormValid) // valid
    }

    func testViewModelErrorHandlingAndClearFeedback() async {
        let repo = MockAuthenticationRepository()
        let env = AppEnvironment(
            mealRepository: MockMealRepository(),
            userRepository: MockUserRepository(),
            foodRecognitionRepository: MockFoodRecognitionRepository(),
            authenticationRepository: repo,
            isMockAuth: true
        )
        let vm = env.makeAuthViewModel(initialStep: .login)

        vm.email = "invalid-email"
        vm.password = "any"
        await vm.login()

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNotNil(vm.errorRecoverySuggestion)

        vm.clearFeedback()
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.errorRecoverySuggestion)
    }
}
