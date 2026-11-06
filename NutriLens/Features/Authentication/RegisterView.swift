//
//  RegisterView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Registration screen.
//

import SwiftUI

public struct RegisterView: View {
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
                        .accessibilityLabel("Quay lại")

                        Spacer()

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, AppSpacing.xs)

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tạo tài khoản mới")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Bắt đầu hành trình chăm sóc sức khỏe và thấu hiểu bữa ăn cùng NutriLens.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Error Banner
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
                            title: "Họ và tên",
                            placeholder: "Nguyễn Văn A",
                            text: $viewModel.displayName,
                            icon: "person.fill",
                            keyboardType: .default,
                            autocapitalization: .words
                        )

                        BotanicalTextField(
                            title: "Địa chỉ Email",
                            placeholder: "name@example.com",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        BotanicalTextField(
                            title: "Mật khẩu",
                            placeholder: "Tối thiểu 8 ký tự, gồm chữ và số",
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        BotanicalTextField(
                            title: "Xác nhận mật khẩu",
                            placeholder: "Nhập lại mật khẩu",
                            text: $viewModel.confirmPassword,
                            icon: "lock.shield.fill",
                            isSecure: true
                        )

                        // Password checklist
                        VStack(alignment: .leading, spacing: 6) {
                            ValidationRow(
                                isPassed: viewModel.password.count >= 8,
                                text: "Tối thiểu 8 ký tự"
                            )
                            ValidationRow(
                                isPassed: viewModel.password.rangeOfCharacter(from: .letters) != nil && viewModel.password.rangeOfCharacter(from: .decimalDigits) != nil,
                                text: "Bao gồm cả chữ cái và chữ số"
                            )
                            ValidationRow(
                                isPassed: !viewModel.password.isEmpty && viewModel.password == viewModel.confirmPassword,
                                text: "Mật khẩu khớp nhau"
                            )
                        }
                        .padding(.top, 4)
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

                    // MARK: - Action Button
                    VStack(spacing: AppSpacing.sm) {
                        PrimaryButton("Đăng ký tài khoản", icon: "checkmark", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.register()
                            }
                        }
                        .disabled(!viewModel.isRegisterFormValid || viewModel.isLoading)

                        // Switch to Login
                        HStack(spacing: 4) {
                            Text("Đã có tài khoản?")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Button {
                                viewModel.clearFeedback()
                                viewModel.currentStep = .login
                            } label: {
                                Text("Đăng nhập")
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

private struct ValidationRow: View {
    let isPassed: Bool
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isPassed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13))
                .foregroundColor(isPassed ? AppColors.primary : AppColors.textTertiary)

            Text(text)
                .font(AppTypography.caption)
                .foregroundColor(isPassed ? AppColors.textPrimary : AppColors.textTertiary)
        }
    }
}
