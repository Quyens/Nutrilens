//
//  ErrorStateView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct ErrorStateView: View {
    private let title: LocalizedStringKey
    private let message: String
    private let retryAction: (() -> Void)?

    public init(
        title: LocalizedStringKey = "Something Went Wrong",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColors.error.opacity(0.12))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(AppColors.error)
            }

            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            if let retryAction {
                PrimaryButton("Try Again", icon: "arrow.clockwise", isFullWidth: false, action: retryAction)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}
