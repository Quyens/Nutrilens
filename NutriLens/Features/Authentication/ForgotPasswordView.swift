//
//  ForgotPasswordView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Password recovery screen with email validation and honest offline/mock messaging.
//

import SwiftUI

public struct ForgotPasswordView: View {
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
                            viewModel.currentStep = .login
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Quay lại")
                                    .font(AppTypography.body)
                            }
                            .foregroundColor(AppColors.primaryDark)
                        }
                        .accessibilityLabel("Quay lại màn hình đăng nhập")

                        Spacer()
                    }
                    .padding(.top, AppSpacing.sm)

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Khôi phục mật khẩu")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Nhập email đã đăng ký của bạn. Chúng tôi sẽ hướng dẫn các bước tiếp theo để tạo mật khẩu mới.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Success / Info Banner
                    if let info = viewModel.infoMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primary)
                            Text(info)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.primarySubtle)
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

                    // MARK: - Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email tài khoản")
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

                    // MARK: - Submit Button
                    PrimaryButton(
                        "Gửi liên kết khôi phục",
                        icon: "paperplane.fill",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.requestPasswordReset()
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    // MARK: - Honest Backend Status Note
                    VStack(spacing: 4) {
                        Text("Lưu ý dịch vụ")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textSecondary)

                        Text("Hiện tại dịch vụ backend trực tuyến đang được phát triển. Không có email nào được gửi ra ngoài thiết bị.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
    }
}
