//
//  FoodImageCard.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presents food photography with calm organic corner radius and metadata overlays.
//

import SwiftUI

public struct FoodImageCard: View {
    private let image: Image?
    private let placeholderIcon: String
    private let title: String?
    private let subtitle: String?
    private let height: CGFloat

    public init(
        image: Image? = nil,
        placeholderIcon: String = "fork.knife",
        title: String? = nil,
        subtitle: String? = nil,
        height: CGFloat = 220
    ) {
        self.image = image
        self.placeholderIcon = placeholderIcon
        self.title = title
        self.subtitle = subtitle
        self.height = height
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipped()
            } else {
                ZStack {
                    AppColors.surfaceSecondary
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: placeholderIcon)
                            .font(.system(size: 38, weight: .light))
                            .foregroundColor(AppColors.sageGreen)
                        Text("Food Photography")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .frame(height: height)
            }

            // Subtle dark scrim gradient for text legibility if title provided
            if title != nil || subtitle != nil {
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.65)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        Text(title)
                            .font(AppTypography.cardTitle)
                            .foregroundColor(.white)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(AppTypography.caption)
                            .foregroundColor(Color.white.opacity(0.85))
                    }
                }
                .padding(AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
