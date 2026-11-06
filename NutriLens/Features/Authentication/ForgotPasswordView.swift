//
//  ForgotPasswordView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Password Recovery screen with full wallpaper integration.
//

import SwiftUI

public struct ForgotPasswordView: View {
    @ObservedObject var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
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
                    // Navigation Header
                    HStack {
                        Button {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .login
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Quay lại")
                                    .font(AppTypography.bodyBold)
                            }
                            .foregroundColor(AppColors.forestGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                        }
                        .accessibilityLabel("Quay lại")

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.top, 54)

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Khôi phục mật khẩu")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
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
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(AppColors.primary.opacity(0.3), lineWidth: 1))
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
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                    }

                    // Form Floating Card
                    VStack(spacing: AppSpacing.md) {
                        BotanicalTextField(
                            title: "Địa chỉ Email",
                            placeholder: "name@example.com",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        PrimaryButton("Gửi yêu cầu khôi phục", icon: "paperplane.fill", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.requestPasswordReset()
                            }
                        }
                        .disabled(viewModel.email.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                        .padding(.top, 4)
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
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
