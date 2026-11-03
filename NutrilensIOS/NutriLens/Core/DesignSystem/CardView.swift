//
//  CardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Base card container adhering strictly to the calm, organic NutriLens Design System.
//

import SwiftUI

public struct CardView<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let isSelected: Bool

    public init(
        padding: CGFloat = AppSpacing.md,
        cornerRadius: CGFloat = AppRadius.card,
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
                    .fill(isSelected ? AppColors.surfaceSecondary : AppColors.surfacePrimary)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? AppColors.sageGreen : AppColors.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: Color.black.opacity(0.025),
                radius: 4,
                x: 0,
                y: 1.5
            )
    }
}
