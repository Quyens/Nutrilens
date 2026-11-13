//
//  ScannedProductResultSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation sheet displaying scanned packaged food details, nutrition scaling,
//  allergen conflict warnings, and direct logging to Meal Diary.
//

import SwiftUI

public struct ScannedProductResultSheet: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            if let product = viewModel.activeProduct {
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 1. Header Card (Botanical Card)
                        productHeaderCard(product: product)

                        // 2. Portion & Serving Scaler
                        portionControlCard(product: product)

                        // 3. Nutrition Facts Grid
                        nutritionFactsCard(product: product)

                        // 4. Allergen & Safety Analysis Banner
                        allergenSafetyCard(product: product)

                        // 5. Ingredients Section
                        ingredientsCard(product: product)

                        // 6. Meal Logging Selector
                        mealLoggingSection()

                        // 7. Action Buttons
                        actionButtons(product: product)
                    }
                    .padding(AppSpacing.md)
                }
                .background(AppColors.background.ignoresSafeArea())
                .navigationTitle("Thông tin sản phẩm")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Đóng") {
                            dismiss()
                            viewModel.resumeScanning()
                        }
                        .foregroundColor(AppColors.primary)
                    }
                }
            } else {
                VStack(spacing: AppSpacing.md) {
                    ProgressView()
                    Text("Đang tải dữ liệu sản phẩm...")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background.ignoresSafeArea())
            }
        }
    }

    // MARK: - Product Header
    private func productHeaderCard(product: PackagedFood) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let brand = product.brand, !brand.isEmpty {
                        Text(brand.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.primary.opacity(0.12))
                            .cornerRadius(6)
                    }

                    Text(product.productName)
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Source Badge
                if let source = viewModel.activeLookupSource {
                    Text(source.badgeTitle)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(source == .bundledCatalogue ? AppColors.leafGreen.opacity(0.2) : AppColors.softSage.opacity(0.3))
                        .foregroundStyle(AppColors.deepForest)
                        .cornerRadius(8)
                }
            }

            Divider()

            HStack {
                Label(product.category, systemImage: "tag.fill")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "barcode")
                        .font(.caption)
                    Text("\(product.barcode) (\(product.barcodeType.rawValue))")
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .stroke(AppColors.leafGreen.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Portion Control Card
    private func portionControlCard(product: PackagedFood) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Khẩu phần ăn")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(formatMultiplier(viewModel.servingMultiplier))x khẩu phần (\(formatGrams(product.serving.servingGramsEquivalent * viewModel.servingMultiplier)) \(product.serving.servingUnit))")
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.primary)
            }

            // Quick Multiplier Chips
            HStack(spacing: AppSpacing.sm) {
                multiplierChip(0.5, label: "0.5x")
                multiplierChip(1.0, label: "1.0x (Chuẩn)")
                multiplierChip(1.5, label: "1.5x")
                multiplierChip(2.0, label: "2.0x")
            }

            // Fine adjustment stepper
            HStack {
                Text("Tùy chỉnh số lượng:")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                HStack(spacing: AppSpacing.md) {
                    Button {
                        if viewModel.servingMultiplier > 0.25 {
                            viewModel.servingMultiplier -= 0.25
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                    }

                    Text(formatMultiplier(viewModel.servingMultiplier))
                        .font(.headline)
                        .frame(minWidth: 40)

                    Button {
                        if viewModel.servingMultiplier < 5.0 {
                            viewModel.servingMultiplier += 0.25
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }

    private func multiplierChip(_ value: Double, label: String) -> some View {
        let isSelected = abs(viewModel.servingMultiplier - value) < 0.05
        return Button {
            viewModel.servingMultiplier = value
        } label: {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(isSelected ? AppColors.primary : AppColors.surfaceBackground)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(AppRadius.medium)
        }
    }

    // MARK: - Nutrition Facts Card
    private func nutritionFactsCard(product: PackagedFood) -> some View {
        let scaledNutr = product.nutrition.scaled(by: viewModel.servingMultiplier)

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Giá trị dinh dưỡng ước tính")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(product.nutrition.basis.shortLabel)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.softSage.opacity(0.3))
                    .cornerRadius(4)
            }

            // Macro grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                macroCard(title: "Calo", value: "\(Int(scaledNutr.calories))", unit: "kcal", color: AppColors.primary)
                macroCard(title: "Đạm", value: String(format: "%.1f", scaledNutr.proteinGrams), unit: "g", color: .blue)
                macroCard(title: "Carb", value: String(format: "%.1f", scaledNutr.carbGrams), unit: "g", color: .orange)
                macroCard(title: "Béo", value: String(format: "%.1f", scaledNutr.fatGrams), unit: "g", color: .purple)
            }

            // Micronutrients if available
            VStack(spacing: 4) {
                if let fiber = scaledNutr.fiberGrams {
                    microRow(name: "Chất xơ", value: String(format: "%.1f", fiber), unit: "g")
                }
                if let sodium = scaledNutr.sodiumMg {
                    microRow(name: "Natri (Sodium)", value: "\(Int(sodium))", unit: "mg")
                }
                if let sugar = scaledNutr.sugarGrams {
                    microRow(name: "Đường tinh luyện", value: String(format: "%.1f", sugar), unit: "g")
                }
                if let calcium = scaledNutr.calciumMg {
                    microRow(name: "Canxi", value: "\(Int(calcium))", unit: "mg")
                }
                if let iron = scaledNutr.ironMg {
                    microRow(name: "Sắt", value: String(format: "%.1f", iron), unit: "mg")
                }
            }
            .padding(.top, 4)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }

    private func macroCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.surfaceBackground)
        .cornerRadius(AppRadius.medium)
    }

    private func microRow(name: String, value: String, unit: String) -> some View {
        HStack {
            Text(name)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text("\(value) \(unit)")
                .font(AppTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Allergen Safety Review Card
    private func allergenSafetyCard(product: PackagedFood) -> some View {
        let eval = viewModel.activeSafetyEvaluation

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: (eval?.hasConflicts == true) ? "exclamationmark.octagon.fill" : "shield.lefthalf.filled")
                    .foregroundColor((eval?.hasConflicts == true) ? .red : AppColors.primary)
                Text("Đối soát dị ứng & An toàn thực phẩm")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            if let eval = eval {
                if eval.hasConflicts {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(eval.conflicts) { conflict in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(conflict.allergen.vietnameseName)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    Text(conflict.reason)
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.9))
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(AppRadius.medium)
                } else if eval.hasIncompleteData {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("Chưa đủ thông tin thành phần để xác minh toàn diện dị ứng.")
                            .font(AppTypography.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(AppRadius.medium)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppColors.primary)
                        Text(eval.safetyNotice)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.leafGreen.opacity(0.12))
                    .cornerRadius(AppRadius.medium)
                }

                // Standard disclaimer
                Text(eval.disclaimer)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 2)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }

    // MARK: - Ingredients
    private func ingredientsCard(product: PackagedFood) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Thành phần công bố")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            if let text = product.ingredientText, !text.isEmpty {
                Text(text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else if !product.ingredients.isEmpty {
                Text(product.ingredients.joined(separator: ", "))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("Chưa có danh sách thành phần chi tiết từ bao bì.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }

    // MARK: - Meal Logging Section
    private func mealLoggingSection() -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Thời gian & Bữa ăn")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(MealType.allCases) { type in
                    mealTypeButton(type: type)
                }
            }

            DatePicker("Thời gian ghi:", selection: $viewModel.selectedLogDate, displayedComponents: [.date, .hourAndMinute])
                .font(AppTypography.subheadline)
                .padding(.top, 4)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }

    private func mealTypeButton(type: MealType) -> some View {
        let isSelected = viewModel.selectedMealType == type
        return Button {
            viewModel.selectedMealType = type
        } label: {
            HStack(spacing: 4) {
                Image(systemName: type.systemIcon)
                Text(type.vietnameseName)
            }
            .font(.caption)
            .fontWeight(isSelected ? .bold : .regular)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppColors.primary : AppColors.surfaceBackground)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .cornerRadius(AppRadius.medium)
        }
    }

    // MARK: - Action Buttons
    private func actionButtons(product: PackagedFood) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Log to Diary button (Primary)
            Button {
                Task {
                    let success = await viewModel.logCurrentProductToDiary()
                    if success {
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("Ghi vào Nhật ký bữa ăn")
                        .font(AppTypography.buttonText)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.primary)
                .cornerRadius(AppRadius.large)
            }

            // Save to Library (if not already in user library)
            Button {
                Task {
                    _ = await viewModel.saveProductToLibrary(product)
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.headline)
                    Text("Lưu bản sao vào kho cá nhân")
                        .font(AppTypography.buttonText)
                }
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.surfaceBackground)
                .cornerRadius(AppRadius.large)
            }
        }
    }

    private func formatMultiplier(_ val: Double) -> String {
        let isInt = val == Double(Int(val))
        return isInt ? "\(Int(val))" : String(format: "%.2f", val)
    }

    private func formatGrams(_ val: Double) -> String {
        let isInt = val == Double(Int(val))
        return isInt ? "\(Int(val))" : String(format: "%.1f", val)
    }
}
