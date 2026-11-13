//
//  SuggestionCardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation card for a smart meal recommendation with macros, explanation, and action triggers.
//

import SwiftUI

public struct SuggestionCardView: View {
    public let suggestion: MealSuggestion
    public let onToggleFavorite: () -> Void
    public let onOpenExplanation: () -> Void
    public let onOpenIngredients: () -> Void
    public let onAddToPlan: () -> Void

    public init(
        suggestion: MealSuggestion,
        onToggleFavorite: @escaping () -> Void,
        onOpenExplanation: @escaping () -> Void,
        onOpenIngredients: @escaping () -> Void,
        onAddToPlan: @escaping () -> Void
    ) {
        self.suggestion = suggestion
        self.onToggleFavorite = onToggleFavorite
        self.onOpenExplanation = onOpenExplanation
        self.onOpenIngredients = onOpenIngredients
        self.onAddToPlan = onAddToPlan
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Top Bar: Source Pill, Match Score Badge & Favorite
            HStack(spacing: 8) {
                // Source Pill
                sourcePill

                Spacer()

                // Match Score Pill
                matchScorePill

                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: suggestion.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(suggestion.isFavorite ? Color(red: 0.90, green: 0.25, blue: 0.30) : AppColors.textTertiary)
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 4, y: 1)
                }
                .accessibilityLabel(suggestion.isFavorite ? "Bỏ yêu thích" : "Yêu thích")
            }

            // 2. Dish Name, Category & Serving
            VStack(alignment: .leading, spacing: 3) {
                Text(suggestion.displayName)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(suggestion.dishCategory)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.mintSurface)
                        .clipShape(Capsule())

                    Text("•")
                        .foregroundColor(AppColors.textTertiary)
                        .font(.system(size: 11))

                    Text(suggestion.suggestedServing)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // 3. Explanation Badges
            explanationTagsView

            // 4. Ingredient Verification & Allergen Status
            statusIndicatorView

            // 5. Nutritional Estimate Breakdown
            macroBreakdownView

            // 6. Action Buttons Bar
            Divider()
                .padding(.vertical, 2)

            actionsBarView
        }
        .padding(16)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: - Subviews
    private var sourcePill: some View {
        HStack(spacing: 4) {
            Image(systemName: suggestion.foodSource.systemIcon)
                .font(.system(size: 10, weight: .bold))
            Text(suggestion.foodSource.vietnameseTitle)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(Color(red: 0.16, green: 0.44, blue: 0.28))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.92, green: 0.96, blue: 0.93))
        .clipShape(Capsule())
    }

    private var matchScorePill: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.12, green: 0.52, blue: 0.32))

            Text("Phù hợp: \(suggestion.recommendationScore)/100")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.12, green: 0.45, blue: 0.28))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(red: 0.88, green: 0.95, blue: 0.90))
        .clipShape(Capsule())
    }

    private var explanationTagsView: some View {
        HStack(spacing: 6) {
            ForEach(suggestion.explanationReasons.prefix(3), id: \.self) { reason in
                HStack(spacing: 3) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                    Text(reason)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color(red: 0.15, green: 0.40, blue: 0.25))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color(red: 0.94, green: 0.97, blue: 0.95))
                .clipShape(Capsule())
            }
        }
    }

    private var statusIndicatorView: some View {
        HStack(spacing: 8) {
            // Ingredient status
            HStack(spacing: 4) {
                Image(systemName: suggestion.ingredientVerificationStatus.systemIcon)
                    .font(.system(size: 10, weight: .semibold))
                Text(suggestion.ingredientVerificationStatus.badgeLabel)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(suggestion.ingredientVerificationStatus == .verified ? AppColors.forestGreen : Color(red: 0.70, green: 0.45, blue: 0.10))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(suggestion.ingredientVerificationStatus == .verified ? AppColors.mintSurface : Color(red: 1.0, green: 0.96, blue: 0.88))
            .clipShape(Capsule())

            // Allergen conflict warning
            if suggestion.hasAllergenConflict {
                HStack(spacing: 3) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.system(size: 10))
                    Text("Có dị ứng đã khai báo")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.20))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(red: 1.0, green: 0.92, blue: 0.92))
                .clipShape(Capsule())
            }
        }
    }

    private var macroBreakdownView: some View {
        HStack(spacing: 8) {
            MacroChip(
                label: "Năng lượng",
                value: "\(Int(suggestion.availableNutritionEstimate.calories))",
                unit: "kcal",
                color: AppColors.forestGreen
            )
            MacroChip(
                label: "Đạm",
                value: "\(Int(suggestion.availableNutritionEstimate.proteinGrams))",
                unit: "g",
                color: AppColors.proteinBlue
            )
            MacroChip(
                label: "Carb",
                value: "\(Int(suggestion.availableNutritionEstimate.carbGrams))",
                unit: "g",
                color: AppColors.carbOrange
            )
            MacroChip(
                label: "Béo",
                value: "\(Int(suggestion.availableNutritionEstimate.fatGrams))",
                unit: "g",
                color: AppColors.fatRed
            )
        }
    }

    private var actionsBarView: some View {
        HStack(spacing: 10) {
            // Explanation Info Button
            Button(action: onOpenExplanation) {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                    Text("Lý do gợi ý")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.16, green: 0.44, blue: 0.28))
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background(AppColors.mintSurface)
                .clipShape(Capsule())
            }

            // Ingredient Button
            Button(action: onOpenIngredients) {
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                        .font(.system(size: 12))
                    Text("Thành phần")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(AppColors.textSecondary)
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background(Color(red: 0.95, green: 0.96, blue: 0.95))
                .clipShape(Capsule())
            }

            Spacer()

            // Add to Weekly Planner Button
            Button(action: onAddToPlan) {
                HStack(spacing: 5) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Lên thực đơn")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(AppColors.forestGreen)
                .clipShape(Capsule())
                .shadow(color: AppColors.forestGreen.opacity(0.25), radius: 4, y: 2)
            }
            .accessibilityIdentifier("add_suggestion_button_\(suggestion.displayName)")
        }
    }
}

private struct MacroChip: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(red: 0.96, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

