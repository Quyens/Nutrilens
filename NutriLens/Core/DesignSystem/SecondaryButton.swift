//
//  SecondaryButton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
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
                        .font(AppTypography.headline)
                }
                Text(title)
                    .font(AppTypography.headline)
                    .lineLimit(1)
            }
            .foregroundColor(isEnabled ? AppColors.primary : AppColors.textTertiary)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xl)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.primarySubtle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
