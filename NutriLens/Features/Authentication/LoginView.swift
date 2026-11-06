//
//  LoginView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Login screen.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background
            AppColors.canvasBackground.ignoresSafeArea()

            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .opacity(0.10)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - Navigation Header
                    HStack {
                        Button {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .welcome
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Quay lại")
                                    .font(AppTypography.bodyBold)
                            }
                            .foregroundColor(AppColors.forestGreen)
                        }
                        .accessibilityLabel("Quay lại màn hình chào mừng")

                        Spacer()

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, AppSpacing.xs)

                    // MARK: - Greeting Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Chào mừng trở lại!")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Đăng nhập để theo dõi và quản lý nhật ký dinh dưỡng của bạn.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Feature Pill
                    HStack(spacing: AppSpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppColors.primary)
                                .frame(width: 36, height: 36)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dinh dưỡng thuần Việt")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textPrimary)
                            Text("Nhận diện chính xác 5.000+ món ăn truyền thống")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(AppSpacing.sm)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                    // MARK: - Development Mock Notice & Autofill
                    if viewModel.isMockMode {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.carbsOrange)
                                Text("Tài khoản Thử nghiệm Nội bộ")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.carbsOrange)
                            }

                            Button {
                                viewModel.email = "demo@nutrilens.vn"
                                viewModel.password = "NutriLens2026!"
                                viewModel.clearFeedback()
                            } label: {
                                Text("Chạm để điền: demo@nutrilens.vn / NutriLens2026!")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.forestGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.surfaceSecondary)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.carbsOrange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    }

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

                    // MARK: - Form Inputs
                    VStack(spacing: AppSpacing.md) {
                        BotanicalTextField(
                            title: "Địa chỉ Email",
                            placeholder: "name@example.com",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        VStack(alignment: .trailing, spacing: 6) {
                            BotanicalTextField(
                                title: "Mật khẩu",
                                placeholder: "Nhập mật khẩu của bạn",
                                text: $viewModel.password,
                                icon: "lock.fill",
                                isSecure: true
                            )

                            Button {
                                viewModel.clearFeedback()
                                viewModel.currentStep = .forgotPassword
                            } label: {
                                Text("Quên mật khẩu?")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.forestGreen)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .fill(AppColors.surfacePrimary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                    // MARK: - Action Buttons
                    VStack(spacing: AppSpacing.sm) {
                        PrimaryButton("Đăng nhập", icon: "arrow.right", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.login()
                            }
                        }
                        .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)

                        // Switch to Register
                        HStack(spacing: 4) {
                            Text("Chưa có tài khoản?")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Button {
                                viewModel.clearFeedback()
                                viewModel.currentStep = .register
                            } label: {
                                Text("Đăng ký ngay")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.top, 6)
                    }
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
