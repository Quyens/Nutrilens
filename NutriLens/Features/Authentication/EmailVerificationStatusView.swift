//
//  EmailVerificationStatusView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Email Verification status screen.
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
            // Background
            AppColors.canvasBackground.ignoresSafeArea()

            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .opacity(0.10)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Verification Icon
                ZStack {
                    Circle()
                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 3)
                        .frame(width: 96, height: 96)

                    Circle()
                        .fill(AppColors.surfaceSecondary)
                        .frame(width: 86, height: 86)

                    Image(systemName: viewModel.currentUser?.isEmailVerified == true ? "checkmark.seal.fill" : "envelope.badge.shield.half.filled")
                        .font(.system(size: 42))
                        .foregroundColor(viewModel.currentUser?.isEmailVerified == true ? AppColors.primary : AppColors.carbsOrange)
                }

                // Title & Subtitle
                VStack(spacing: 8) {
                    Text(viewModel.currentUser?.isEmailVerified == true ? "Email đã được xác thực" : "Kiểm tra hộp thư của bạn")
                        .font(AppTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    if let email = viewModel.currentUser?.email {
                        Text(email)
                            .font(AppTypography.headlineBold)
                            .foregroundColor(AppColors.primary)
                    }

                    Text(viewModel.currentUser?.isEmailVerified == true ?
                         "Tài khoản của bạn đã được xác thực an toàn. Bạn có thể sử dụng đầy đủ các tính năng của NutriLens." :
                         "NutriLens đã ghi nhận địa chỉ email này. Trong môi trường hiện tại, bạn có thể tiếp tục ngay vào ứng dụng.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: AppSpacing.sm) {
                    PrimaryButton("Tiếp tục vào ứng dụng", icon: "arrow.right") {
                        onContinue()
                    }

                    if viewModel.currentUser?.isEmailVerified != true {
                        SecondaryButton("Gửi lại email xác thực", icon: "arrow.clockwise") {
                            viewModel.infoMessage = "Yêu cầu gửi lại đã ghi nhận trên thiết bị."
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}
