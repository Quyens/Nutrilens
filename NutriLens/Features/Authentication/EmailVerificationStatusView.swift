//
//  EmailVerificationStatusView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presents email verification status and provides honest offline resend messaging.
//

import SwiftUI

public struct EmailVerificationStatusView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onContinue: () -> Void

    public init(viewModel: AuthViewModel, onContinue: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            AppColors.subtleGlowGradient.ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Verification Icon
                ZStack {
                    Circle()
                        .fill(AppColors.primarySubtle)
                        .frame(width: 88, height: 88)

                    Image(systemName: viewModel.currentUser?.isEmailVerified == true ? "checkmark.seal.fill" : "envelope.badge.shield.half.filled")
                        .font(.system(size: 40))
                        .foregroundColor(viewModel.currentUser?.isEmailVerified == true ? AppColors.primary : AppColors.carbsOrange)
                }

                // Title & Subtitle
                VStack(spacing: 8) {
                    Text(viewModel.currentUser?.isEmailVerified == true ? "Email đã được xác thực" : "Kiểm tra hộp thư của bạn")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.textPrimary)

                    if let email = viewModel.currentUser?.email {
                        Text(email)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.primaryDark)
                    }

                    Text(viewModel.currentUser?.isEmailVerified == true ?
                         "Tài khoản của bạn đã được xác thực thành công. Bạn có thể sử dụng tất cả tính năng của NutriLens." :
                         "Chúng tôi đã ghi nhận địa chỉ email của bạn. Trong môi trường thử nghiệm, bạn có thể tiếp tục ngay vào ứng dụng.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }

                Spacer()

                // Actions
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton("Tiếp tục vào ứng dụng", icon: "arrow.right") {
                        onContinue()
                    }

                    if viewModel.currentUser?.isEmailVerified != true {
                        SecondaryButton("Gửi lại email xác thực", icon: "arrow.clockwise") {
                            viewModel.infoMessage = "Chế độ thử nghiệm: Yêu cầu gửi lại đã ghi nhận (không gửi email thực)."
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
