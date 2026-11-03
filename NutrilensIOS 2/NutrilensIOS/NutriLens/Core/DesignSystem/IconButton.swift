//
//  IconButton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Standardized circular or squircle icon button adhering to minimum 44pt touch targets.
//

import SwiftUI

public enum IconButtonStyle {
    case circular
    case squircle
    case subtle
}

public struct IconButton: View {
    private let icon: String
    private let accessibilityLabel: LocalizedStringKey
    private let style: IconButtonStyle
    private let size: CGFloat
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        icon: String,
        accessibilityLabel: LocalizedStringKey,
        style: IconButtonStyle = .circular,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.style = style
        self.size = max(size, 44) // Guarantee Apple Human Interface Guidelines 44pt minimum touch target
        self.action = action
    }

    public init(
        _ icon: String,
        accessibilityLabel: LocalizedStringKey? = nil,
        style: IconButtonStyle = .circular,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel ?? LocalizedStringKey(icon)
        self.style = style
        self.size = max(size, 44)
        self.action = action
    }

    public var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        }) {
            ZStack {
                switch style {
                case .circular:
                    Circle()
                        .fill(AppColors.surfaceSecondary)
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 1))
                case .squircle:
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppColors.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                case .subtle:
                    Color.clear
                }

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
            }
            .frame(width: size, height: size)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}
