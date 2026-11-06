//
//  AuthViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  MainActor presentation ViewModel coordinating authentication flows, form validation, and session states.
//

import Foundation
import SwiftUI

public enum AuthStep: Hashable, Sendable {
    case welcome
    case login
    case register
    case forgotPassword
    case verificationStatus
    case accountManagement
}

@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: - Navigation State
    @Published public var currentStep: AuthStep = .welcome
    @Published public private(set) var session: AuthenticationSession = .unauthenticated

    // MARK: - Form Inputs
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    @Published public var displayName: String = ""
    @Published public var isPasswordVisible: Bool = false
    @Published public var isConfirmPasswordVisible: Bool = false

    // MARK: - UI Feedback States
    @Published public private(set) var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var errorRecoverySuggestion: String? = nil
    @Published public var infoMessage: String? = nil
    @Published public var showingLogoutConfirmation: Bool = false
    @Published public var showingDeleteConfirmation: Bool = false

    // MARK: - Development Mock Detection
    public let isMockMode: Bool

    // MARK: - Use Cases
    private let getAuthSessionUseCase: GetAuthSessionUseCaseProtocol
    private let loginUseCase: LoginUseCaseProtocol
    private let registerUseCase: RegisterUseCaseProtocol
    private let signInWithAppleUseCase: SignInWithAppleUseCaseProtocol
    private let requestPasswordResetUseCase: RequestPasswordResetUseCaseProtocol
    private let continueAsGuestUseCase: ContinueAsGuestUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let deleteAccountUseCase: DeleteAccountUseCaseProtocol

    // Callback when authentication or guest continuation completes
    public var onAuthCompleted: (() -> Void)?

    public init(
        getAuthSessionUseCase: GetAuthSessionUseCaseProtocol,
        loginUseCase: LoginUseCaseProtocol,
        registerUseCase: RegisterUseCaseProtocol,
        signInWithAppleUseCase: SignInWithAppleUseCaseProtocol,
        requestPasswordResetUseCase: RequestPasswordResetUseCaseProtocol,
        continueAsGuestUseCase: ContinueAsGuestUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        deleteAccountUseCase: DeleteAccountUseCaseProtocol,
        isMockMode: Bool = false,
        onAuthCompleted: (() -> Void)? = nil
    ) {
        self.getAuthSessionUseCase = getAuthSessionUseCase
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.signInWithAppleUseCase = signInWithAppleUseCase
        self.requestPasswordResetUseCase = requestPasswordResetUseCase
        self.continueAsGuestUseCase = continueAsGuestUseCase
        self.logoutUseCase = logoutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.isMockMode = isMockMode
        self.onAuthCompleted = onAuthCompleted
    }

    // MARK: - Computed Properties
    public var currentUser: AuthUser? {
        session.user
    }

    public var isAuthenticated: Bool {
        session.isAuthenticated
    }

    public var isGuest: Bool {
        session.isGuest
    }

    public var isLoginFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    public var isRegisterFormValid: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !cleanEmail.isEmpty && password.count >= 8 && password == confirmPassword
    }

    // MARK: - Actions

    public func loadSession() async {
        do {
            self.session = try await getAuthSessionUseCase.execute()
        } catch {
            self.session = .unauthenticated
        }
    }

    public func login() async {
        clearFeedback()
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await loginUseCase.execute(email: email, password: password)
            self.session = result
            onAuthCompleted?()
        } catch let err as AuthError {
            self.errorMessage = err.errorDescription
            self.errorRecoverySuggestion = err.recoverySuggestion
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func register() async {
        clearFeedback()
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await registerUseCase.execute(
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                displayName: displayName
            )
            self.session = result
            onAuthCompleted?()
        } catch let err as AuthError {
            self.errorMessage = err.errorDescription
            self.errorRecoverySuggestion = err.recoverySuggestion
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func signInWithApple(idToken: String = "mock_apple_token", nonce: String = "mock_nonce", fullName: String? = nil) async {
        clearFeedback()
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await signInWithAppleUseCase.execute(idToken: idToken, nonce: nonce, fullName: fullName)
            self.session = result
            onAuthCompleted?()
        } catch let err as AuthError {
            self.errorMessage = err.errorDescription
            self.errorRecoverySuggestion = err.recoverySuggestion
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func requestPasswordReset() async {
        clearFeedback()
        isLoading = true
        defer { isLoading = false }

        do {
            try await requestPasswordResetUseCase.execute(email: email)
            self.infoMessage = "Nếu email tồn tại trong hệ thống, hướng dẫn đặt lại mật khẩu đã được gửi đi."
        } catch let err as AuthError {
            self.errorMessage = err.errorDescription
            self.errorRecoverySuggestion = err.recoverySuggestion
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func continueAsGuest() async {
        clearFeedback()
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await continueAsGuestUseCase.execute()
            self.session = result
            onAuthCompleted?()
        } catch {
            self.errorMessage = "Không thể khởi tạo phiên Khách: \(error.localizedDescription)"
        }
    }

    public func logout() async {
        clearFeedback()
        isLoading = true
        defer {
            isLoading = false
            showingLogoutConfirmation = false
        }

        do {
            try await logoutUseCase.execute()
            self.session = .unauthenticated
            self.currentStep = .welcome
            resetForm()
        } catch {
            self.errorMessage = "Đăng xuất thất bại: \(error.localizedDescription)"
        }
    }

    public func deleteAccount() async {
        clearFeedback()
        isLoading = true
        defer {
            isLoading = false
            showingDeleteConfirmation = false
        }

        do {
            try await deleteAccountUseCase.execute()
            self.session = .unauthenticated
            self.currentStep = .welcome
            resetForm()
        } catch let err as AuthError {
            self.errorMessage = err.errorDescription
            self.errorRecoverySuggestion = err.recoverySuggestion
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func resetForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        isPasswordVisible = false
        isConfirmPasswordVisible = false
        clearFeedback()
    }

    public func clearFeedback() {
        errorMessage = nil
        errorRecoverySuggestion = nil
        infoMessage = nil
    }
}
