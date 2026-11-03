//
//  EmptyStateView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Clean empty state presentation utilizing centralized SF symbols and calm brand tokens.
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
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(AppColors.sageGreen)
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

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text(actionTitle)
                            .font(AppTypography.captionBold)
                    }
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 8)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))
                }
                .padding(.top, AppSpacing.xs)
            }
        }
        .padding(.vertical, AppSpacing.xl)
        .padding(.horizontal, AppSpacing.md)
        .frame(maxWidth: .infinity)
    }
}
