//
//  MacroNutrientIndicator.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Clear macronutrient progress indicator (Protein, Carbs, Fat, Fiber).
//

import SwiftUI

public enum MacroType {
    case protein
    case carbs
    case fat
    case fiber

    public var title: LocalizedStringKey {
        switch self {
        case .protein: return "Protein"
        case .carbs: return "Carbs"
        case .fat: return "Fat"
        case .fiber: return "Fiber"
        }
    }

    public var icon: String {
        switch self {
        case .protein: return "bolt.fill"
        case .carbs: return "leaf.fill"
        case .fat: return "drop.fill"
        case .fiber: return "circle.grid.2x1.fill"
        }
    }

    public var color: Color {
        switch self {
        case .protein: return AppColors.proteinOcean
        case .carbs: return AppColors.carbAmber
        case .fat: return AppColors.fatCoral
        case .fiber: return AppColors.sageGreen
        }
    }
}

public struct MacroNutrientIndicator: View {
    private let type: MacroType
    private let consumedGrams: Double
    private let targetGrams: Double

    public init(
        type: MacroType,
        consumedGrams: Double,
        targetGrams: Double
    ) {
        self.type = type
        self.consumedGrams = consumedGrams
        self.targetGrams = targetGrams
    }

    private var progress: Double {
        guard targetGrams > 0 else { return 0 }
        return min(consumedGrams / targetGrams, 1.0)
    }

    public var body: some View {
        CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.md) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: type.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(type.color)

                    Text(type.title)
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textSecondary)
                }

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(consumedGrams))")
                        .font(AppTypography.nutritionValueMedium)
                        .foregroundColor(AppColors.textPrimary)
                    Text("g")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(type.color.opacity(0.18))
                            .frame(height: 4)

                        Capsule()
                            .fill(type.color)
                            .frame(width: max(geo.size.width * CGFloat(progress), 3), height: 4)
                    }
                }
                .frame(height: 4)

                Text("Target \(Int(targetGrams))g")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
