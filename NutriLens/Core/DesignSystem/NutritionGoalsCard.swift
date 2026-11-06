//
//  NutritionGoalsCard.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Featured card on Profile displaying daily nutritional targets with botanical styling.
//

import SwiftUI

public struct NutritionGoalsCard: View {
    private let dailyCalories: Double
    private let dailyProteinGrams: Double
    private let dailyCarbGrams: Double
    private let dailyFatGrams: Double
    private let onOpenEditor: () -> Void

    public init(
        dailyCalories: Double,
        dailyProteinGrams: Double,
        dailyCarbGrams: Double,
        dailyFatGrams: Double,
        onOpenEditor: @escaping () -> Void
    ) {
        self.dailyCalories = dailyCalories
        self.dailyProteinGrams = dailyProteinGrams
        self.dailyCarbGrams = dailyCarbGrams
        self.dailyFatGrams = dailyFatGrams
        self.onOpenEditor = onOpenEditor
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Header Row
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.surfaceSecondary)
                            .frame(width: 32, height: 32)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mục tiêu dinh dưỡng")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Kế hoạch năng lượng hàng ngày")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Button(action: onOpenEditor) {
                    HStack(spacing: 4) {
                        Text("Thiết lập")
                            .font(AppTypography.captionBold)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                }
            }

            // Macro Metrics Grid
            HStack(spacing: AppSpacing.xs) {
                MacroPill(
                    title: "Calo",
                    value: "\(Int(dailyCalories))",
                    unit: "kcal",
                    color: AppColors.primary
                )

                MacroPill(
                    title: "Đạm",
                    value: "\(Int(dailyProteinGrams))",
                    unit: "g",
                    color: AppColors.proteinBlue
                )

                MacroPill(
                    title: "Carb",
                    value: "\(Int(dailyCarbGrams))",
                    unit: "g",
                    color: AppColors.carbsOrange
                )

                MacroPill(
                    title: "Béo",
                    value: "\(Int(dailyFatGrams))",
                    unit: "g",
                    color: AppColors.fatCoral
                )
            }
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
}

private struct MacroPill: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(value)
                    .font(AppTypography.headlineBold)
                    .foregroundColor(AppColors.textPrimary)
                    .monospacedDigit()
                Text(unit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }

            Capsule()
                .fill(color)
                .frame(height: 3)
                .padding(.horizontal, 6)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(AppColors.canvasBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}
