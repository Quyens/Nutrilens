//
//  LoginView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Login screen with full wallpaper integration.
//

import SwiftUI

public struct LoginView: View {
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
                    // MARK: - Navigation Header
                    HStack {
                        Button {
                            viewModel.clearFeedback()
                            viewModel.currentStep = .welcome
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
                        .accessibilityLabel("Quay lại màn hình chào mừng")

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
                    .padding(.top, AppSpacing.md)

                    // MARK: - Greeting Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Chào mừng trở lại! 👋")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Đăng nhập để theo dõi và quản lý nhật ký dinh dưỡng món Việt.")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Feature Pill
                    HStack(spacing: AppSpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 36, height: 36)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dinh dưỡng món Việt chuẩn calo")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textPrimary)
                            Text("Quét AI & ghi nhận nhanh 5.000+ món ăn truyền thống")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                    // MARK: - Development Mock Notice & Autofill
                    if viewModel.isMockMode {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.carbsOrange)
                                Text("Tài khoản Thử nghiệm Nội bộ (Mock)")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.carbsOrange)
                            }

                            Button {
                                viewModel.email = "demo@nutrilens.vn"
                                viewModel.password = "NutriLens2026!"
                                viewModel.clearFeedback()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 11))
                                    Text("Điền nhanh: demo@nutrilens.vn")
                                        .font(AppTypography.captionBold)
                                }
                                .foregroundColor(AppColors.forestGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(AppColors.surfaceSecondary)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.carbsOrange.opacity(0.3), lineWidth: 1))
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
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                    }

                    // MARK: - Main Floating Form Card
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
                            .padding(.top, 4)
                        }

                        PrimaryButton("Đăng nhập", icon: "arrow.right", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.login()
                            }
                        }
                        .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                        .padding(.top, 6)
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

                    // MARK: - Switch to Register
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
                    .padding(.top, 4)
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
