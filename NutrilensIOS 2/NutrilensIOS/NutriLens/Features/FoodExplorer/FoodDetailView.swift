//
//  FoodDetailView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Food Details & Interactive Portion Calculator Screen.
//

import SwiftUI

public struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    public let dish: VietnameseDishProfile
    @ObservedObject public var viewModel: FoodExplorerViewModel

    @State private var servingGrams: Double
    @State private var selectedPreset: PortionPreset? = .standard
    @State private var showLogSheet: Bool = false
    @State private var showDirectInputSheet: Bool = false
    @State private var directInputText: String = ""

    public init(dish: VietnameseDishProfile, viewModel: FoodExplorerViewModel) {
        self.dish = dish
        self.viewModel = viewModel
        self._servingGrams = State(initialValue: dish.standardServingGrams)
    }

    private var scaledNutrition: ScaledNutrition {
        PortionCalculationService.scale(profile: dish, targetGrams: servingGrams)
    }

    private var isFav: Bool {
        viewModel.isFavorite(dishId: dish.id)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.canvasBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Hero Image & Top Actions
                    heroHeader

                    // Dish Title & Editorial Description
                    dishInfoSection

                    // Portion Calculator
                    portionCalculatorSection

                    // Nutrition Breakdown Card
                    nutritionBreakdownCard

                    // Data Provenance & Reliability
                    provenanceCard

                    // Bottom spacing for sticky action button
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }

            // Sticky Bottom Action Bar
            bottomActionBar
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showLogSheet) {
            LogFromExplorerSheet(dish: dish, scaledNutrition: scaledNutrition)
        }
        .sheet(isPresented: $showDirectInputSheet) {
            directInputSheet
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .top) {
            // Food Hero Image
            Image(dish.assetImageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.clear, Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )

            // Top action buttons
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimaryDark)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .accessibilityLabel("Quay lại")

                Spacer()

                Button(action: {
                    viewModel.toggleFavorite(dishId: dish.id)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isFav ? Color(hex: "E97970") : AppColors.textPrimaryDark)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .accessibilityLabel(isFav ? "Xóa khỏi yêu thích" : "Thêm vào yêu thích")
            }
            .padding(AppSpacing.md)
        }
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Dish Info Section
    private var dishInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                // Category Pill
                Text(dish.category)
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.mintSurface)
                    .clipShape(Capsule())

                // Reference Code Pill
                Text(dish.referenceCode)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
            }

            Text(dish.vietnameseName)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(dish.englishName)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !dish.summary.isEmpty {
                Text(dish.summary)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimaryDark.opacity(0.85))
                    .lineSpacing(4)
                    .padding(.top, 4)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Portion Calculator Section
    private var portionCalculatorSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bộ tính khẩu phần")
                        .font(AppTypography.sectionTitle)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Tùy chỉnh định lượng khẩu phần thực tế")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: {
                    directInputText = "\(Int(servingGrams))"
                    showDirectInputSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                        Text("Nhập gram")
                            .font(AppTypography.captionBold)
                    }
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.mintSurface)
                    .clipShape(Capsule())
                }
            }

            // Interactive Stepper Control
            HStack(spacing: AppSpacing.md) {
                Button(action: {
                    adjustPortion(delta: -25)
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(servingGrams <= PortionCalculationService.minGrams ? AppColors.textTertiary : AppColors.primaryGreen)
                        .frame(width: 48, height: 48)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 1))
                }
                .disabled(servingGrams <= PortionCalculationService.minGrams)
                .accessibilityIdentifier("portion_stepper_minus")

                Spacer()

                VStack(spacing: 2) {
                    Text("\(Int(servingGrams))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)

                    Text("gam (g)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: {
                    adjustPortion(delta: 25)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(servingGrams >= PortionCalculationService.maxGrams ? AppColors.textTertiary : AppColors.primaryGreen)
                        .frame(width: 48, height: 48)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 1))
                }
                .disabled(servingGrams >= PortionCalculationService.maxGrams)
                .accessibilityIdentifier("portion_stepper_plus")
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)

            // Preset Pills
            HStack(spacing: AppSpacing.xs) {
                ForEach(PortionPreset.allCases) { preset in
                    let isSelected = selectedPreset == preset
                    Button(action: {
                        applyPreset(preset)
                    }) {
                        VStack(spacing: 2) {
                            Text(preset.title)
                                .font(AppTypography.subheadlineBold)
                                .foregroundColor(isSelected ? .white : AppColors.textPrimary)

                            Text(preset.label)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(isSelected ? .white.opacity(0.9) : AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? AppColors.primaryGreen : AppColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .stroke(isSelected ? AppColors.primaryGreen : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("preset_\(preset.title)")
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Nutrition Breakdown Card
    private var nutritionBreakdownCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Giá trị dinh dưỡng tương ứng")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                HStack(spacing: 3) {
                    Text("\(Int(scaledNutrition.calories))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                    Text("kcal")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Macronutrient 4-grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.xs) {
                MacroStatBox(
                    label: "Chất đạm",
                    value: String(format: "%.1f", scaledNutrition.protein),
                    unit: "g",
                    color: AppColors.proteinBlue
                )

                MacroStatBox(
                    label: "Tinh bột",
                    value: String(format: "%.1f", scaledNutrition.carbs),
                    unit: "g",
                    color: AppColors.carbsOrange
                )

                MacroStatBox(
                    label: "Chất béo",
                    value: String(format: "%.1f", scaledNutrition.fat),
                    unit: "g",
                    color: AppColors.fatCoral
                )

                MacroStatBox(
                    label: "Chất xơ",
                    value: String(format: "%.1f", scaledNutrition.fiber),
                    unit: "g",
                    color: AppColors.primaryGreen
                )
            }

            // Macro distribution bar
            let totalGrams = max(0.1, scaledNutrition.protein + scaledNutrition.carbs + scaledNutrition.fat)
            GeometryReader { geo in
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(AppColors.proteinBlue)
                        .frame(width: max(4, geo.size.width * CGFloat(scaledNutrition.protein / totalGrams)))
                    Rectangle()
                        .fill(AppColors.carbsOrange)
                        .frame(width: max(4, geo.size.width * CGFloat(scaledNutrition.carbs / totalGrams)))
                    Rectangle()
                        .fill(AppColors.fatCoral)
                        .frame(width: max(4, geo.size.width * CGFloat(scaledNutrition.fat / totalGrams)))
                }
                .clipShape(Capsule())
            }
            .frame(height: 6)
            .padding(.top, 4)

            // Legend
            HStack(spacing: AppSpacing.md) {
                LegendDot(title: "Đạm (P)", color: AppColors.proteinBlue)
                LegendDot(title: "Carbs (C)", color: AppColors.carbsOrange)
                LegendDot(title: "Béo (F)", color: AppColors.fatCoral)
                Spacer()
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Data Provenance & Limitations Card
    private var provenanceCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(AppColors.primaryGreen)
                    .font(.system(size: 16))

                Text("Nguồn gốc dữ liệu & Giới hạn")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)
            }

            VStack(alignment: .leading, spacing: 6) {
                ProvenanceRow(title: "Nguồn tham chiếu", detail: dish.provenance)
                ProvenanceRow(title: "Mã tra cứu", detail: dish.referenceCode)
                ProvenanceRow(title: "Phương pháp", detail: dish.verificationMethod)
                ProvenanceRow(title: "Lưu ý phương sai", detail: dish.limitations)
            }
            .padding(.top, 4)

            Divider()
                .padding(.vertical, 4)

            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.top, 1)

                Text(PortionCalculationService.nutritionDisclaimer)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ước tính")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: 3) {
                        Text("\(Int(scaledNutrition.calories))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)

                        Text("kcal / \(Int(servingGrams))g")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Button(action: {
                    showLogSheet = true
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Ghi vào nhật ký")
                            .font(AppTypography.button)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .frame(height: 50)
                    .background(AppColors.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                    .shadow(color: AppColors.primaryGreen.opacity(0.35), radius: 6, x: 0, y: 3)
                }
                .accessibilityIdentifier("button_log_to_diary")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.surfacePrimary.ignoresSafeArea(edges: .bottom))
        }
    }

    // MARK: - Direct Numeric Input Sheet
    private var directInputSheet: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("Nhập khối lượng khẩu phần chính xác")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, AppSpacing.lg)

                HStack {
                    TextField("350", text: $directInputText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(width: 140)
                        .padding(.vertical, 10)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(AppColors.primaryGreen, lineWidth: 1.5))

                    Text("gam (g)")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textSecondary)
                }

                Text("Hạn mức an toàn: 10g đến 2000g")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textTertiary)

                Button(action: {
                    if let value = Double(directInputText), value >= PortionCalculationService.minGrams, value <= PortionCalculationService.maxGrams {
                        servingGrams = value
                        selectedPreset = nil
                        showDirectInputSheet = false
                    }
                }) {
                    Text("Áp dụng")
                        .font(AppTypography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)

                Spacer()
            }
            .background(AppColors.canvasBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { showDirectInputSheet = false }
                }
            }
        }
        .presentationDetents([.height(280)])
    }

    // MARK: - Helper Methods
    private func adjustPortion(delta: Double) {
        let newGrams = min(max(servingGrams + delta, PortionCalculationService.minGrams), PortionCalculationService.maxGrams)
        servingGrams = newGrams
        selectedPreset = nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func applyPreset(_ preset: PortionPreset) {
        selectedPreset = preset
        servingGrams = (dish.standardServingGrams * preset.multiplier).rounded()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Supporting Subviews
private struct MacroStatBox: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(unit)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}

private struct LegendDot: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

private struct ProvenanceRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)

            Text(detail)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}
