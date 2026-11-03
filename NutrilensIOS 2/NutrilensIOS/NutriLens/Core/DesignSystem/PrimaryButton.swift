//
//  PrimaryButton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Standardized primary call-to-action button (Radius: 16 pt).
//

import SwiftUI

public struct PrimaryButton: View {
    private let title: LocalizedStringKey
    private let icon: String?
    private let isLoading: Bool
    private let isFullWidth: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        isLoading: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryActionText))
                        .scaleEffect(0.9)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(AppTypography.cardTitle)
                    .lineLimit(1)
            }
            .foregroundColor(isEnabled ? AppColors.primaryActionText : AppColors.textTertiary)
            .padding(.vertical, 14)
            .padding(.horizontal, AppSpacing.lg)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .fill(isEnabled ? AppColors.primaryAction : AppColors.disabled)
            )
            .shadow(
                color: isEnabled ? Color.black.opacity(0.06) : .clear,
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .disabled(!isEnabled || isLoading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
