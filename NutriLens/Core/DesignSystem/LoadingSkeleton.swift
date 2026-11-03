//
//  LoadingSkeleton.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Subtle shimmering skeleton placeholder for smooth loading state transitions.
//

import SwiftUI

public struct LoadingSkeleton: View {
    private let height: CGFloat
    private let cornerRadius: CGFloat
    @State private var isAnimating: Bool = false

    public init(
        height: CGFloat = 80,
        cornerRadius: CGFloat = AppRadius.card
    ) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppColors.surfaceSecondary)
            .frame(height: height)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        AppColors.surfacePrimary.opacity(isAnimating ? 0.45 : 0.05),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading content...")
    }
}
