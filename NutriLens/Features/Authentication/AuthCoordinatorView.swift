//
//  AuthCoordinatorView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Root navigation coordinator hosting the authentication and account flows.
//

import SwiftUI

public struct AuthCoordinatorView: View {
    @StateObject private var viewModel: AuthViewModel
    private let onDismiss: (() -> Void)?

    public init(viewModel: AuthViewModel, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            switch viewModel.currentStep {
            case .welcome:
                WelcomeAuthView(
                    viewModel: viewModel,
                    onDismiss: onDismiss
                )
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))

            case .login:
                LoginView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))

            case .register:
                RegisterView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))

            case .forgotPassword:
                ForgotPasswordView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))

            case .verificationStatus:
                EmailVerificationStatusView(
                    viewModel: viewModel,
                    onContinue: {
                        onDismiss?()
                    }
                )
                .transition(.opacity)

            case .accountManagement:
                AccountManagementView(
                    viewModel: viewModel,
                    onDismiss: {
                        onDismiss?()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
        .task {
            await viewModel.loadSession()
        }
    }
}
