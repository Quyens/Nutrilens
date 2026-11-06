//
//  WelcomeAuthView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Welcome and gateway screen presenting Authentication options, Apple Sign-In, and Guest continuation.
//

import SwiftUI
import AuthenticationServices

public struct WelcomeAuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onDismiss: (() -> Void)?

    public init(viewModel: AuthViewModel, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Botanical background wallpaper & glow
            AppColors.background.ignoresSafeArea()
            AppColors.subtleGlowGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // MARK: - Dismiss button if presented modally
                    if let dismissAction = onDismiss {
                        HStack {
                            Spacer()
                            Button(action: dismissAction) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .accessibilityLabel("Đóng màn hình xác thực")
                        }
                        .padding(.top, AppSpacing.sm)
                    }

                    // MARK: - Mock Mode Banner (Explicitly labeled)
                    if viewModel.isMockMode {
                        HStack(spacing: 8) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .foregroundColor(.orange)
                            Text("Chế độ Thử nghiệm Nội bộ (Development Mock Active)")
                                .font(AppTypography.captionBold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    // MARK: - Hero Botanical Branding
                    VStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primarySubtle)
                                .frame(width: 96, height: 96)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primaryDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 6) {
                            Text("NutriLens")
                                .font(AppTypography.largeTitle)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Nhận Diện Dinh Dưỡng • Thuần Việt")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.primaryDark)
                        }

                        Text("Ghi lại bữa ăn Việt thông minh với AI trên thiết bị, theo dõi macro và quản lý mục tiêu sức khỏe.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.lg)
                    }
                    .padding(.top, AppSpacing.lg)

                    // MARK: - Error / Info Banner
                    if let err = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.error)
                                Text(err)
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.error)
                            }
                            if let suggestion = viewModel.errorRecoverySuggestion {
                                Text(suggestion)
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.leading, 24)
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.error.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    }

                    // MARK: - Action Buttons
                    VStack(spacing: AppSpacing.md) {
                        // 1. Sign in with Apple button
                        Button {
                            Task {
                                await viewModel.signInWithApple()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 19, weight: .semibold))
                                Text("Tiếp tục với Apple")
                                    .font(AppTypography.button)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                        }
                        .disabled(viewModel.isLoading)

                        // 2. Email Login Button
                        PrimaryButton("Đăng nhập bằng Email", icon: "envelope.fill", isLoading: false) {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .login
                        }
                        .disabled(viewModel.isLoading)

                        // 3. Register Button
                        SecondaryButton("Tạo tài khoản mới", icon: "person.badge.plus") {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .register
                        }
                        .disabled(viewModel.isLoading)

                        // 4. Guest Mode Button
                        Button {
                            Task {
                                await viewModel.continueAsGuest()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("Tiếp tục với tư cách Khách")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text("Trải nghiệm đầy đủ tính năng on-device không cần tài khoản")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.button)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel("Tiếp tục với tư cách Khách, trải nghiệm không cần tài khoản")
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: - Privacy Note
                    Text("Bằng việc tiếp tục, dữ liệu của bạn được bảo mật tuyệt đối trên thiết bị theo cam kết quyền riêng tư của NutriLens.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.bottom, AppSpacing.xl)
                }
            }
        }
    }
}
