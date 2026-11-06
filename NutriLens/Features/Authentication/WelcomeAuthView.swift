//
//  WelcomeAuthView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Welcome & Authentication Gateway with full wallpaper integration.
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
            // MARK: - Full Botanical Wallpaper (Matching HomeView)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - Top Close Button
                    HStack {
                        if viewModel.isMockMode {
                            HStack(spacing: 6) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 11))
                                Text("Chế độ Thử nghiệm (Mock)")
                                    .font(AppTypography.captionBold)
                            }
                            .foregroundColor(AppColors.carbsOrange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
                        }

                        Spacer()

                        if let dismissAction = onDismiss {
                            Button(action: dismissAction) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 36, height: 36)
                                        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)

                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .accessibilityLabel("Đóng màn hình xác thực")
                        }
                    }
                    .padding(.top, 54)

                    // MARK: - Botanical Hero Branding
                    VStack(spacing: AppSpacing.md) {
                        // Emblem
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 88, height: 88)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, y: 3)

                            Circle()
                                .stroke(AppColors.primary.opacity(0.25), lineWidth: 2)
                                .frame(width: 88, height: 88)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(12))
                        }

                        VStack(spacing: 6) {
                            Text("NutriLens")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)

                            Text("Theo dõi dinh dưỡng & AI nhận diện món ăn Việt")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.sm)
                        }

                        // Feature Highlights Pill
                        HStack(spacing: 8) {
                            FeatureMiniTag(icon: "sparkles", text: "AI On-Device")
                            FeatureMiniTag(icon: "fork.knife", text: "5.000+ Món Việt")
                            FeatureMiniTag(icon: "lock.shield.fill", text: "Bảo Mật Cục Bộ")
                        }
                        .padding(.top, 2)
                    }
                    .padding(.top, AppSpacing.xs)

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
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .stroke(AppColors.error.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // MARK: - Action Buttons Card
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Bắt đầu trải nghiệm")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)

                            Text("Chọn phương thức đăng nhập thuận tiện nhất")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 4)

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
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
                        }
                        .disabled(viewModel.isLoading)

                        // Or Divider
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(AppColors.border)
                                .frame(height: 1)
                            Text("HOẶC")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.textTertiary)
                            Rectangle()
                                .fill(AppColors.border)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 2)

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
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.primary)
                                Text("Tiếp tục với vai trò khách")
                                    .font(AppTypography.bodyBold)
                                    .foregroundColor(AppColors.forestGreen)
                            }
                            .padding(.vertical, 8)
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel("Tiếp tục sử dụng ứng dụng dưới chế độ khách")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .padding(.top, 4)

                    // Terms Notice
                    Text("Bằng việc tiếp tục, bạn đồng ý với Điều khoản Sử dụng và Chính sách Bảo mật của NutriLens.")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
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
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.primary)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 1)
        .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))
    }
}
