//
//  EmptyStateView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct EmptyStateView: View {
    private let icon: String
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    public init(
        icon: String = "tray",
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColors.primarySubtle)
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(AppColors.primary)
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

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primary)
                        .padding(.vertical, AppSpacing.xs)
                        .padding(.horizontal, AppSpacing.md)
                        .background(
                            Capsule()
                                .stroke(AppColors.primary, lineWidth: 1.5)
                        )
                }
                .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}
