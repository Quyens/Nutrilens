//
//  MealHistoryRow.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Standardized meal log row component with thumbnail, meal type, and macro pills.
//

import SwiftUI

public struct MealHistoryRow: View {
    private let title: String
    private let mealTypeName: String
    private let mealTypeIcon: String
    private let timeString: String
    private let calories: Double
    private let proteinGrams: Double
    private let carbGrams: Double
    private let fatGrams: Double
    private let image: Image?
    private let action: (() -> Void)?

    public init(
        title: String,
        mealTypeName: String,
        mealTypeIcon: String,
        timeString: String,
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        image: Image? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.mealTypeName = mealTypeName
        self.mealTypeIcon = mealTypeIcon
        self.timeString = timeString
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.image = image
        self.action = action
    }

    public init(meal: MealRecord, action: (() -> Void)? = nil) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        self.init(
            title: meal.items.map(\.vietnameseName).joined(separator: ", "),
            mealTypeName: meal.mealType.rawValue,
            mealTypeIcon: meal.mealType.systemIcon,
            timeString: formatter.string(from: meal.timestamp),
            calories: meal.totalCalories,
            proteinGrams: meal.totalProteinGrams,
            carbGrams: meal.totalCarbGrams,
            fatGrams: meal.totalFatGrams,
            image: nil,
            action: action
        )
    }

    public var body: some View {
        Button(action: {
            action?()
        }) {
            CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                HStack(spacing: AppSpacing.md) {
                    // Thumbnail or Icon Squircle
                    ZStack {
                        if let image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 48, height: 48)

                            Image(systemName: mealTypeIcon)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }

                    // Dish and Metadata
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(AppTypography.cardTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(mealTypeName)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Text("•")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textTertiary)

                            Text(timeString)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }

                    Spacer()

                    // Calorie and Macro Breakdown
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(Int(calories))")
                                .font(AppTypography.nutritionValueSmall)
                                .foregroundColor(AppColors.textPrimary)
                            Text("kcal")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Text("P:\(Int(proteinGrams)) C:\(Int(carbGrams)) F:\(Int(fatGrams))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
