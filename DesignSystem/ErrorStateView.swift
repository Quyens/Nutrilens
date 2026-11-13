//
//  ErrorStateView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Clear actionable error presentation with localized recovery suggestion.
//

import SwiftUI

public struct ErrorStateView: View {
    private let title: LocalizedStringKey
    private let message: String
    private let retryAction: (() -> Void)?

    public init(
        title: LocalizedStringKey = "Unable to Complete Action",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.error.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(AppColors.error)
            }

            VStack(spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.sectionTitle)
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
