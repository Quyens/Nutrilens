//
//  ConfirmationSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Reusable confirmation modal sheet conforming to NutriLens Design Tokens.
//

import SwiftUI

public struct ConfirmationSheet: View {
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let confirmTitle: LocalizedStringKey
    private let cancelTitle: LocalizedStringKey
    private let isDestructive: Bool
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        confirmTitle: LocalizedStringKey = "Confirm",
        cancelTitle: LocalizedStringKey = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Drag indicator bar
            Capsule()
                .fill(AppColors.border)
                .frame(width: 36, height: 4)
                .padding(.top, AppSpacing.xs)

            VStack(spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
            .padding(.top, AppSpacing.xs)

            VStack(spacing: AppSpacing.xs) {
                if isDestructive {
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(AppTypography.cardTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                                    .fill(AppColors.error)
                            )
                    }
                } else {
                    PrimaryButton(confirmTitle, action: onConfirm)
                }

                SecondaryButton(cancelTitle, action: onCancel)
            }
            .padding(.top, AppSpacing.sm)
        }
        .padding(AppSpacing.screenHorizontal)
        .background(AppColors.background)
    }
}
