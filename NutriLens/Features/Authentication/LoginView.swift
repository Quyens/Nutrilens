//
//  LoginView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Email and Password login screen with field validation, show/hide password, and mock demo shortcuts.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            AppColors.subtleGlowGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - Header
                    HStack {
                        Button {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .welcome
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Quay lại")
                                    .font(AppTypography.body)
                            }
                            .foregroundColor(AppColors.primaryDark)
                        }
                        .accessibilityLabel("Quay lại màn hình chào mừng")

                        Spacer()
                    }
                    .padding(.top, AppSpacing.sm)

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Chào mừng trở lại!")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Đăng nhập để đồng bộ thông tin và quản lý nhật ký dinh dưỡng.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Development Mock Notice & Autofill
                    if viewModel.isMockMode {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Chế độ Thử Nghiệm (Mock Account)")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(.blue)
                            }
                            Text("Chạm để điền nhanh tài khoản thử nghiệm pre-configured:")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Button {
                                viewModel.email = "demo@nutrilens.vn"
                                viewModel.password = "NutriLens2026!"
                                viewModel.clearFeedback()
                            } label: {
                                Text("Điền: demo@nutrilens.vn / NutriLens2026!")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.primaryDark)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppColors.primarySubtle)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.08))
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

                    // MARK: - Input Form
                    VStack(spacing: AppSpacing.md) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textSecondary)

                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 20)

                                TextField("ban@example.com", text: $viewModel.email)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.emailAddress)
                                    .font(AppTypography.body)
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Mật khẩu")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.textSecondary)

                                Spacer()

                                Button("Quên mật khẩu?") {
                                    viewModel.clearFeedback()
                                    viewModel.currentStep = .forgotPassword
                                }
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.primaryDark)
                            }

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 20)

                                if viewModel.isPasswordVisible {
                                    TextField("Mật khẩu", text: $viewModel.password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                        .font(AppTypography.body)
                                } else {
                                    SecureField("Mật khẩu", text: $viewModel.password)
                                        .font(AppTypography.body)
                                }

                                Button {
                                    viewModel.isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .accessibilityLabel(viewModel.isPasswordVisible ? "Ẩn mật khẩu" : "Hiện mật khẩu")
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }

                    // MARK: - Submit Button
                    PrimaryButton(
                        "Đăng nhập",
                        icon: "arrow.right",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isLoginFormValid)

                    // MARK: - Register Link
                    HStack(spacing: 4) {
                        Text("Chưa có tài khoản?")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Button("Đăng ký ngay") {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .register
                        }
                        .font(AppTypography.subheadlineBold)
                        .foregroundColor(AppColors.primaryDark)
                    }
                    .padding(.top, AppSpacing.sm)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
    }
}
