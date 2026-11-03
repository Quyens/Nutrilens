//
//  SecondaryButton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Subdued action button conforming to 16 pt radius and calm surface styling.
//

import SwiftUI

public struct SecondaryButton: View {
    private let title: LocalizedStringKey
    private let icon: String?
    private let isFullWidth: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(AppTypography.cardTitle)
                    .lineLimit(1)
            }
            .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
            .padding(.vertical, 14)
            .padding(.horizontal, AppSpacing.lg)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .fill(isEnabled ? AppColors.surfaceSecondary : AppColors.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(isEnabled ? AppColors.border : AppColors.border.opacity(0.4), lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
