//
//  WelcomeAuthView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Welcome & Authentication Gateway.
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
            // Background
            AppColors.canvasBackground.ignoresSafeArea()

            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .opacity(0.12)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - Top Close Button (if presented modally)
                    if let dismissAction = onDismiss {
                        HStack {
                            Spacer()
                            Button(action: dismissAction) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .accessibilityLabel("Đóng màn hình xác thực")
                        }
                        .padding(.top, AppSpacing.xs)
                    }

                    // MARK: - Development Mock Badge
                    if viewModel.isMockMode {
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 11))
                            Text("Chế độ Thử nghiệm Nội bộ (Mock)")
                                .font(AppTypography.captionBold)
                        }
                        .foregroundColor(AppColors.carbsOrange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.carbsOrange.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    // MARK: - Botanical Hero Branding
                    VStack(spacing: AppSpacing.md) {
                        // Emblem
                        ZStack {
                            Circle()
                                .stroke(AppColors.primary.opacity(0.15), lineWidth: 3)
                                .frame(width: 90, height: 90)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.surfaceSecondary, AppColors.softGreen.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 38, weight: .bold))
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
                                .font(AppTypography.heroTitle)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Theo dõi dinh dưỡng dễ dàng, khoa học và cá nhân hóa.")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.md)
                        }

                        // Feature Highlights Pill
                        HStack(spacing: 12) {
                            FeatureMiniTag(icon: "sparkles", text: "AI On-Device")
                            FeatureMiniTag(icon: "fork.knife", text: "Món Việt Chuẩn")
                            FeatureMiniTag(icon: "lock.shield", text: "Bảo Mật 100%")
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, AppSpacing.sm)

                    // MARK: - Error Banner
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

                    // MARK: - Action Buttons Section
                    VStack(spacing: AppSpacing.sm) {
                        // 1. Sign In With Apple (Native Button Look)
                        Button {
                            Task {
                                await viewModel.signInWithApple()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Tiếp tục với Apple")
                                    .font(AppTypography.button)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                            .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                        }
                        .disabled(viewModel.isLoading)

                        // 2. Email Login Button
                        PrimaryButton("Đăng nhập với Email", icon: "envelope.fill", isLoading: viewModel.isLoading) {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .login
                        }

                        // 3. Register Account Button
                        SecondaryButton("Tạo tài khoản mới", icon: "person.badge.plus") {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .register
                        }

                        // 4. Guest Mode Button
                        Button {
                            Task {
                                await viewModel.continueAsGuest()
                                onDismiss?()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 15))
                                Text("Tiếp tục với vai trò khách")
                                    .font(AppTypography.bodyBold)
                            }
                            .foregroundColor(AppColors.forestGreen)
                            .padding(.vertical, 12)
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel("Tiếp tục sử dụng ứng dụng dưới chế độ khách")
                    }
                    .padding(.top, AppSpacing.sm)

                    // Terms Notice
                    Text("Bằng việc tiếp tục, bạn đồng ý với Điều khoản Sử dụng và Chính sách Bảo mật của NutriLens.")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.lg)
                }
                .padding(AppSpacing.screenHorizontal)
            }
        }
    }
}

private struct FeatureMiniTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.primary)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(AppColors.surfaceSecondary)
        .clipShape(Capsule())
    }
}
