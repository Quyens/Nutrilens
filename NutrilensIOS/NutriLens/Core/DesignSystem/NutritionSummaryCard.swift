//
//  NutritionSummaryCard.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Structured daily caloric overview card adhering to calm, organic brand identity.
//

import SwiftUI

public struct NutritionSummaryCard: View {
    private let consumedCalories: Double
    private let targetCalories: Double
    private let remainingCalories: Double
    private let progress: Double

    public init(
        consumedCalories: Double,
        targetCalories: Double,
        remainingCalories: Double,
        progress: Double
    ) {
        self.consumedCalories = consumedCalories
        self.targetCalories = targetCalories
        self.remainingCalories = remainingCalories
        self.progress = min(max(progress, 0), 1.0)
    }

    public var body: some View {
        CardView(padding: AppSpacing.md + 4, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Top Header Row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CALORIE BUDGET")
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.8)

                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("\(Int(remainingCalories))")
                                .font(AppTypography.nutritionValueLarge)
                                .foregroundColor(AppColors.textPrimary)

                            Text("kcal remaining")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    // Percentage Badge
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColors.calorieGold)
                        Text("\(Int(progress * 100))%")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.border, lineWidth: 0.8))
                }

                // Clean Linear Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.surfaceSecondary)
                            .frame(height: 8)

                        Capsule()
                            .fill(AppColors.primaryAction)
                            .frame(width: max(geo.size.width * CGFloat(progress), 8), height: 8)
                    }
                }
                .frame(height: 8)

                // Sub-metrics row
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Consumed")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                        Text("\(Int(consumedCalories)) kcal")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Target")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                        Text("\(Int(targetCalories)) kcal")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
}
