//
//  CustomFoodCardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Botanical Card View for User Custom Foods.
//

import SwiftUI

public struct CustomFoodCardView: View {
    public let food: CustomFood
    public let onSelect: () -> Void
    public let onToggleFavorite: () -> Void
    public let onQuickLog: () -> Void

    public init(
        food: CustomFood,
        onSelect: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void,
        onQuickLog: @escaping () -> Void
    ) {
        self.food = food
        self.onSelect = onSelect
        self.onToggleFavorite = onToggleFavorite
        self.onQuickLog = onQuickLog
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                // Top row: Category tag & favorite button
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundColor(AppColors.primaryGreen)
                            .font(.system(size: 13))
                        Text(food.category)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())

                    if let brand = food.brand, !brand.isEmpty {
                        Text(brand)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: onToggleFavorite) {
                        Image(systemName: food.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 15))
                            .foregroundColor(food.isFavorite ? Color(hex: "E04F5F") : AppColors.textTertiary)
                            .padding(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Food Name & Serving
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("1 \(food.servingUnit) (\(Int(food.servingGrams))g)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Divider()
                    .background(AppColors.border)

                // Bottom row: Calories & Macros badges + Quick Log button
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(Int(food.caloriesPerServing))")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(AppColors.primaryGreen)
                            Text("kcal")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        HStack(spacing: 6) {
                            Text("Đ: \(food.proteinGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "2B6CB0"))
                            Text("C: \(food.carbGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "C05621"))
                            Text("B: \(food.fatGrams, specifier: "%.1f")g")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "C53030"))
                        }
                    }

                    Spacer()

                    Button(action: onQuickLog) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Ghi")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
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

