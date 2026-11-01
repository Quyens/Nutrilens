//
//  PrimaryButton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
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
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(AppTypography.headline)
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.vertical, AppSpacing.md + 2)
            .padding(.horizontal, AppSpacing.xl)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(isEnabled ? AnyShapeStyle(AppColors.primaryGradient) : AnyShapeStyle(AppColors.primary.opacity(0.35)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: isEnabled ? AppColors.primary.opacity(0.35) : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!isEnabled || isLoading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
