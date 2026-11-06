//
//  AIConfidenceIndicator.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Transparent indicator of on-device AI recognition confidence.
//  Carefully distinguishes image classification confidence from nutritional precision.
//

import SwiftUI

public struct AIConfidenceIndicator: View {
    private let confidence: Double
    private let isVerifiedByUser: Bool

    public init(confidence: Double, isVerifiedByUser: Bool = false) {
        self.confidence = min(max(confidence, 0), 1.0)
        self.isVerifiedByUser = isVerifiedByUser
    }

    private var confidenceLevel: (text: String, icon: String, color: Color) {
        if isVerifiedByUser {
            return ("User Confirmed", "checkmark.circle.fill", AppColors.success)
        } else if confidence >= 0.85 {
            return ("High Visual Match (\(Int(confidence * 100))%)", "sparkle", AppColors.forestGreen)
        } else if confidence >= 0.60 {
            return ("Moderate Match (\(Int(confidence * 100))%)", "questionmark.circle", AppColors.warning)
        } else {
            return ("Low Match — Please Verify", "exclamationmark.triangle", AppColors.error)
        }
    }

    public var body: some View {
        HStack(spacing: 5) {
            Image(systemName: confidenceLevel.icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(confidenceLevel.color)

            Text(confidenceLevel.text)
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.surfaceSecondary)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recognition confidence: \(Int(confidence * 100)) percent")
    }
}
