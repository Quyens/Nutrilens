//
//  EmailVerificationStatusView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Email Verification status screen with full wallpaper integration.
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
            // MARK: - Full Botanical Wallpaper (Matching HomeView)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Center Floating Card
                VStack(spacing: 20) {
                    // Verification Icon
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 96, height: 96)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 3)

                        Circle()
                            .stroke(AppColors.primary.opacity(0.25), lineWidth: 2)
                            .frame(width: 96, height: 96)

                        Image(systemName: viewModel.currentUser?.isEmailVerified == true ? "checkmark.seal.fill" : "envelope.badge.shield.half.filled")
                            .font(.system(size: 42))
                            .foregroundColor(viewModel.currentUser?.isEmailVerified == true ? AppColors.primary : AppColors.carbsOrange)
                    }

                    // Title & Subtitle
                    VStack(spacing: 8) {
                        Text(viewModel.currentUser?.isEmailVerified == true ? "Email đã được xác thực" : "Kiểm tra hộp thư của bạn")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        if let email = viewModel.currentUser?.email {
                            Text(email)
                                .font(AppTypography.headlineBold)
                                .foregroundColor(AppColors.primary)
                        }

                        Text(viewModel.currentUser?.isEmailVerified == true ?
                             "Tài khoản của bạn đã được xác thực an toàn. Bạn có thể sử dụng đầy đủ các tính năng của NutriLens." :
                             "NutriLens đã ghi nhận địa chỉ email này. Trong phiên bản cục bộ, bạn có thể tiếp tục ngay vào ứng dụng.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.sm)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .padding(.horizontal, AppSpacing.screenHorizontal)

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
