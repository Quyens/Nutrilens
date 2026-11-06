//
//  BotanicalProfileHeader.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical profile hero card with avatar, badges, and organic accents.
//

import SwiftUI

public struct BotanicalProfileHeader: View {
    private let displayName: String
    private let isGuest: Bool
    private let goalTitle: String

    public init(
        displayName: String,
        isGuest: Bool,
        goalTitle: String
    ) {
        self.displayName = displayName
        self.isGuest = isGuest
        self.goalTitle = goalTitle
    }

    public var body: some View {
        HStack(spacing: AppSpacing.md) {
            // MARK: - Botanical Avatar Emblem
            ZStack {
                // Outer subtle organic ring
                Circle()
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 2)
                    .frame(width: 66, height: 66)

                // Background gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.surfaceSecondary, AppColors.softGreen.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)

                // Icon / Initial
                if isGuest {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    Text(initials(from: displayName))
                        .font(AppTypography.headlineBold)
                        .foregroundColor(AppColors.textPrimary)
                }

                // Small badge indicator on avatar edge
                Circle()
                    .fill(isGuest ? AppColors.forestGreen : AppColors.primary)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
                    .offset(x: 20, y: 20)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isGuest ? "Ảnh đại diện khách NutriLens" : "Ảnh đại diện \(displayName)")

            // MARK: - User Info & Status Badges
            VStack(alignment: .leading, spacing: 6) {
                Text(isGuest ? "Khách NutriLens" : displayName)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                // Badges row
                HStack(spacing: 6) {
                    // Account type pill
                    HStack(spacing: 4) {
                        Image(systemName: isGuest ? "person.crop.circle" : "checkmark.seal.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(isGuest ? "Chế độ Khách" : "Đã xác thực")
                            .font(AppTypography.captionBold)
                    }
                    .foregroundColor(isGuest ? AppColors.forestGreen : AppColors.primaryDark)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())

                    // Dietary goal pill
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11, weight: .semibold))
                        Text(goalTitle)
                            .font(AppTypography.caption)
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.canvasBackground)
                    .overlay(
                        Capsule().stroke(AppColors.border, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.surfacePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
