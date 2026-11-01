//
//  LoadingView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct LoadingView: View {
    private let message: LocalizedStringKey

    public init(_ message: LocalizedStringKey = "Loading...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                .scaleEffect(1.3)

            Text(message)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.opacity(0.8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}
