//
//  CardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct CardView<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let isSelected: Bool

    public init(
        padding: CGFloat = AppSpacing.md,
        cornerRadius: CGFloat = AppRadius.lg,
        isSelected: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.isSelected = isSelected
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppColors.cardSelectedGradient) : AnyShapeStyle(AppColors.surface))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? AppColors.primary : AppColors.border.opacity(0.35),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primary.opacity(0.12) : Color.black.opacity(0.04),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 2
            )
    }
}
