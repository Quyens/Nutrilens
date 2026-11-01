//
//  NutritionResultView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct NutritionResultView: View {
    @StateObject private var viewModel: NutritionResultViewModel
    private let onConfirm: (FoodItem) -> Void
    private let onCancel: () -> Void

    public init(
        item: FoodItem,
        onConfirm: @escaping (FoodItem) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: NutritionResultViewModel(foodItem: item))
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Dish Header Card
                    CardView {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            HStack {
                                Text(viewModel.scaledItem.vietnameseName)
                                    .font(AppTypography.title2)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                ConfidenceBadge(confidence: viewModel.scaledItem.confidence)
                            }

                            Text(viewModel.scaledItem.name)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)

                            Divider().padding(.vertical, 2)

                            // Serving Size Adjuster
                            HStack {
                                Text("Portion Size")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()

                                Button(action: { viewModel.adjustGrams(by: -50) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(AppColors.primary)
                                }

                                Text("\(Int(viewModel.servingSizeGrams))g")
                                    .font(AppTypography.headline)
                                    .frame(minWidth: 60)

                                Button(action: { viewModel.adjustGrams(by: 50) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                        }
                    }

                    // Calories Big Stat
                    CardView {
                        VStack(spacing: AppSpacing.xs) {
                            Text("Estimated Energy")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Text("\(Int(viewModel.scaledItem.calories))")
                                .font(AppTypography.metricLarge)
                                .foregroundColor(AppColors.primaryDark)

                            Text("Kilocalories (kcal)")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Macronutrients breakdown
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Macronutrients")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: AppSpacing.sm) {
                            NutrientCard(
                                title: "Protein",
                                value: "\(String(format: "%.1f", viewModel.scaledItem.proteinGrams))g",
                                color: AppColors.protein
                            )
                            NutrientCard(
                                title: "Carbohydrates",
                                value: "\(String(format: "%.1f", viewModel.scaledItem.carbGrams))g",
                                color: AppColors.carbs
                            )
                            NutrientCard(
                                title: "Fat",
                                value: "\(String(format: "%.1f", viewModel.scaledItem.fatGrams))g",
                                color: AppColors.fat
                            )
                        }

                        HStack(spacing: AppSpacing.sm) {
                            NutrientCard(
                                title: "Dietary Fiber",
                                value: "\(String(format: "%.1f", viewModel.scaledItem.fiberGrams))g",
                                color: AppColors.primary
                            )
                        }
                    }

                    // Confirmation Action
                    PrimaryButton("Log This Meal", icon: "checkmark") {
                        onConfirm(viewModel.scaledItem)
                    }
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Nutrition Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

private struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
            Text("\(Int(confidence * 100))% match")
                .font(AppTypography.captionBold)
        }
        .foregroundColor(AppColors.primaryDark)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColors.primarySubtle)
        .clipShape(Capsule())
    }
}

private struct NutrientCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Text(value)
                    .font(AppTypography.title3)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
