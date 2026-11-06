//
//  RegisterView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Registration screen with full wallpaper integration.
//

import SwiftUI

public struct RegisterView: View {
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
                        Text("Tạo tài khoản mới")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Bắt đầu hành trình dinh dưỡng khoa học và cá nhân hóa cùng NutriLens.")
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
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                    }

                    // MARK: - Form Floating Card
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
                                text: "Mật khẩu xác nhận khớp nhau"
                            )
                        }
                        .padding(.top, 4)

                        PrimaryButton("Đăng ký tài khoản", icon: "checkmark", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.register()
                            }
                        }
                        .disabled(!viewModel.isRegisterFormValid || viewModel.isLoading)
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
                    .padding(.top, 4)
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
