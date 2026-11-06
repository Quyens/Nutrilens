//
//  RegisterView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Registration screen with name, email, password strength feedback, and confirm password checks.
//

import SwiftUI

public struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    private var hasMinimumLength: Bool {
        viewModel.password.count >= 8
    }

    private var hasLettersAndNumbers: Bool {
        let hasLetters = viewModel.password.range(of: #"[A-Za-z]"#, options: .regularExpression) != nil
        let hasNumbers = viewModel.password.range(of: #"[0-9]"#, options: .regularExpression) != nil
        return hasLetters && hasNumbers
    }

    private var passwordsMatch: Bool {
        !viewModel.password.isEmpty && viewModel.password == viewModel.confirmPassword
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
                        Text("Bắt đầu cùng NutriLens")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Tạo tài khoản để cá nhân hóa mục tiêu dinh dưỡng và lưu trữ thực đơn.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                        // Display Name Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Họ và tên")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textSecondary)

                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 20)

                                TextField("Nguyễn Văn A", text: $viewModel.displayName)
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
                            Text("Mật khẩu")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textSecondary)

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

                            // Password Strength Indicators
                            VStack(alignment: .leading, spacing: 4) {
                                RequirementRow(title: "Ít nhất 8 ký tự", satisfied: hasMinimumLength)
                                RequirementRow(title: "Bao gồm chữ cái và chữ số", satisfied: hasLettersAndNumbers)
                            }
                            .padding(.top, 4)
                        }

                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Xác nhận mật khẩu")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textSecondary)

                            HStack {
                                Image(systemName: "lock.shield")
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 20)

                                if viewModel.isConfirmPasswordVisible {
                                    TextField("Nhập lại mật khẩu", text: $viewModel.confirmPassword)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                        .font(AppTypography.body)
                                } else {
                                    SecureField("Nhập lại mật khẩu", text: $viewModel.confirmPassword)
                                        .font(AppTypography.body)
                                }

                                Button {
                                    viewModel.isConfirmPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: viewModel.isConfirmPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .accessibilityLabel(viewModel.isConfirmPasswordVisible ? "Ẩn mật khẩu xác nhận" : "Hiện mật khẩu xác nhận")
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )

                            if !viewModel.confirmPassword.isEmpty {
                                RequirementRow(title: "Mật khẩu khớp nhau", satisfied: passwordsMatch)
                                    .padding(.top, 4)
                            }
                        }
                    }

                    // MARK: - Submit Button
                    PrimaryButton(
                        "Đăng ký tài khoản",
                        icon: "checkmark.circle.fill",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.register()
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isRegisterFormValid)

                    // MARK: - Login Link
                    HStack(spacing: 4) {
                        Text("Đã có tài khoản?")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Button("Đăng nhập") {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .login
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

private struct RequirementRow: View {
    let title: String
    let satisfied: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: satisfied ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13))
                .foregroundColor(satisfied ? AppColors.primary : AppColors.textTertiary)
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(satisfied ? AppColors.textPrimary : AppColors.textTertiary)
        }
    }
}
