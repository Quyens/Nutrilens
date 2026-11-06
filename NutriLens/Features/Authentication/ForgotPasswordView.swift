//
//  ForgotPasswordView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Password Recovery screen.
//

import SwiftUI

public struct ForgotPasswordView: View {
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
                    // Navigation Header
                    HStack {
                        Button {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .login
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
                        Text("Khôi phục mật khẩu")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Nhập email tài khoản để nhận hướng dẫn khôi phục mật khẩu.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Info / Success Banner
                    if let info = viewModel.infoMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(AppColors.primary)
                            Text(info)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    }

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

                    // Form Card
                    VStack(spacing: AppSpacing.md) {
                        BotanicalTextField(
                            title: "Địa chỉ Email",
                            placeholder: "name@example.com",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
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

                    // Action Button
                    VStack(spacing: AppSpacing.sm) {
                        PrimaryButton("Gửi yêu cầu khôi phục", icon: "paperplane.fill", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.requestPasswordReset()
                            }
                        }
                        .disabled(viewModel.email.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                    }
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
