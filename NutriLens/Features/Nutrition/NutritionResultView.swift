import SwiftUI

public struct NutritionResultView: View {
    @StateObject private var viewModel: NutritionResultViewModel
    @State private var showingNameEditor = false
    @State private var editedName = ""
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // 1. Food Image / Presentation Hero
                    FoodImageCard(
                        image: nil,
                        placeholderIcon: "fork.knife",
                        title: viewModel.scaledItem.vietnameseName,
                        subtitle: viewModel.scaledItem.name,
                        height: 200
                    )

                    // 2. Recognition Confidence & Dish Verification
                    HStack {
                        AIConfidenceIndicator(confidence: viewModel.scaledItem.confidence)

                        Spacer()

                        Button {
                            editedName = viewModel.scaledItem.vietnameseName
                            showingNameEditor = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                Text("Edit Name")
                                    .font(AppTypography.captionBold)
                            }
                            .foregroundColor(AppColors.primaryAction)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.surfaceSecondary)
                            .clipShape(Capsule())
                        }
                    }

                    // 3. Portion Size Interactive Adjuster
                    CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                        VStack(spacing: AppSpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Portion Size")
                                        .font(AppTypography.cardTitle)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("Adjust to match your actual serving")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                HStack(spacing: AppSpacing.xs) {
                                    IconButton("minus", size: 36) {
                                        #if canImport(UIKit)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        #endif
                                        viewModel.adjustGrams(by: -50)
                                    }

                                    Text("\(Int(viewModel.servingSizeGrams))g")
                                        .font(AppTypography.nutritionValueSmall)
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(minWidth: 54)

                                    IconButton("plus", size: 36) {
                                        #if canImport(UIKit)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        #endif
                                        viewModel.adjustGrams(by: 50)
                                    }
                                }
                            }

                            // Quick preset weight chips
                            HStack(spacing: AppSpacing.xs) {
                                PortionPresetChip(label: "Light (300g)", targetGrams: 300, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setGrams(300)
                                }
                                PortionPresetChip(label: "Standard (450g)", targetGrams: 450, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setGrams(450)
                                }
                                PortionPresetChip(label: "Generous (600g)", targetGrams: 600, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setGrams(600)
                                }
                            }
                        }
                    }

                    // 4. Energy & Calorie Hero Card
                    CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                        HStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.calorieGold.opacity(0.18))
                                    .frame(width: 56, height: 56)

                                Image(systemName: "flame.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.calorieGold)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Estimated Energy")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)

                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(Int(viewModel.scaledItem.calories))")
                                        .font(AppTypography.nutritionValueLarge)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("kcal")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Per \(Int(viewModel.servingSizeGrams))g portion")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }

                    // 5. Macronutrients Breakdown Grid
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Macronutrients")
                            .font(AppTypography.sectionTitle)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: AppSpacing.sm) {
                            NutrientBreakdownCard(
                                title: "Protein",
                                value: String(format: "%.1fg", viewModel.scaledItem.proteinGrams),
                                icon: "bolt.fill",
                                color: AppColors.proteinOcean
                            )
                            NutrientBreakdownCard(
                                title: "Carbs",
                                value: String(format: "%.1fg", viewModel.scaledItem.carbGrams),
                                icon: "leaf.fill",
                                color: AppColors.carbAmber
                            )
                            NutrientBreakdownCard(
                                title: "Fat",
                                value: String(format: "%.1fg", viewModel.scaledItem.fatGrams),
                                icon: "drop.fill",
                                color: AppColors.fatCoral
                            )
                        }

                        HStack(spacing: AppSpacing.sm) {
                            NutrientBreakdownCard(
                                title: "Dietary Fiber",
                                value: String(format: "%.1fg", viewModel.scaledItem.fiberGrams),
                                icon: "chart.bar.doc.horizontal",
                                color: AppColors.forestGreen
                            )
                        }
                    }

                    // 6. Action Button Dock
                    VStack(spacing: AppSpacing.sm) {
                        PrimaryButton("Log This Meal", icon: "checkmark.circle.fill") {
                            onConfirm(viewModel.scaledItem)
                        }

                        SecondaryButton("Cancel", icon: "xmark") {
                            onCancel()
                        }
                    }
                    .padding(.top, AppSpacing.xs)

                    // 7. Transparent AI & Nutritional Disclaimer (Mandatory per GEMINI.md)
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textTertiary)
                            Text("Nutritional Information Source")
                                .font(AppTypography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textTertiary)
                        }

                        Text("Nutritional figures are computed using standard Vietnamese Food Composition Tables and USDA reference benchmarks, adjusted proportionally for your portion size. AI confidence applies solely to visual classification.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.sm)
                    }
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xs)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Nutrition Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onCancel)
                }
            }
            .alert("Edit Dish Name", isPresented: $showingNameEditor) {
                TextField("Dish Name", text: $editedName)
                Button("Save") {
                    if !editedName.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.updateName(editedName)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

private struct PortionPresetChip: View {
    let label: String
    let targetGrams: Double
    let currentGrams: Double
    let action: () -> Void

    private var isSelected: Bool {
        abs(currentGrams - targetGrams) < 5
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.captionBold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.primaryAction : AppColors.surfaceSecondary)
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : AppColors.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct NutrientBreakdownCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                    Text(title)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Text(value)
                    .font(AppTypography.cardTitle)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
