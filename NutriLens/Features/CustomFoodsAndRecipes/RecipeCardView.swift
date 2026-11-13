//
//  RecipeCardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Botanical Card View for User Recipes.
//

import SwiftUI

public struct RecipeCardView: View {
    public let recipe: Recipe
    public let onSelect: () -> Void
    public let onToggleFavorite: () -> Void
    public let onQuickLog: () -> Void

    public init(
        recipe: Recipe,
        onSelect: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void,
        onQuickLog: @escaping () -> Void
    ) {
        self.recipe = recipe
        self.onSelect = onSelect
        self.onToggleFavorite = onToggleFavorite
        self.onQuickLog = onQuickLog
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                // Top row: Servings, total time, favorite
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(Color(hex: "2F855A"))
                            .font(.system(size: 13))
                        Text("\(recipe.servings) khẩu phần")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "2F855A"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())

                    if recipe.totalTimeMinutes > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text("\(recipe.totalTimeMinutes)p")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Button(action: onToggleFavorite) {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 15))
                            .foregroundColor(recipe.isFavorite ? Color(hex: "E04F5F") : AppColors.textTertiary)
                            .padding(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Recipe Name & Ingredients Count
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("\(recipe.ingredients.count) nguyên liệu • \(Int(recipe.standardServingGrams))g / phần")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Divider()
                    .background(AppColors.border)

                // Bottom row: Calories per serving & Macros + Quick Log button
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(Int(recipe.perServingNutrition.calories))")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(AppColors.primaryGreen)
                            Text("kcal / phần")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        HStack(spacing: 6) {
                            Text("Đ: \(recipe.perServingNutrition.proteinGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "2B6CB0"))
                            Text("C: \(recipe.perServingNutrition.carbGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "C05621"))
                            Text("B: \(recipe.perServingNutrition.fatGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "C53030"))
                        }
                    }

                    Spacer()

                    Button(action: onQuickLog) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Ghi 1 phần")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.primaryGreen)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

