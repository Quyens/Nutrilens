//
//  AddSuggestionToPlanSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Bridges Smart Suggestions directly into Phase 04 Weekly Meal Planner.
//  NOTE: Saves planned snapshot; does NOT pollute actual Meal Diary intake.
//

import SwiftUI

public struct AddSuggestionToPlanSheet: View {
    @Environment(\.dismiss) private var dismiss

    public let suggestion: MealSuggestion
    public let initialDate: Date
    public let initialCategory: PlannedMealCategory?
    public let onConfirm: (MealSuggestion, Date, PlannedMealCategory, Double, String?) -> Void

    @State private var selectedDate: Date
    @State private var selectedCategory: PlannedMealCategory
    @State private var servingMultiplier: Double = 1.0
    @State private var notesText: String = ""

    public init(
        suggestion: MealSuggestion,
        initialDate: Date = Date(),
        initialCategory: PlannedMealCategory? = nil,
        onConfirm: @escaping (MealSuggestion, Date, PlannedMealCategory, Double, String?) -> Void
    ) {
        self.suggestion = suggestion
        self.initialDate = initialDate
        self.initialCategory = initialCategory
        self.onConfirm = onConfirm
        _selectedDate = State(initialValue: initialDate)
        _selectedCategory = State(initialValue: initialCategory ?? .lunch)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.98, blue: 0.97).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Dish Summary Card
                        dishSummaryCard

                        // 2. Schedule Date & Meal Category
                        scheduleTargetCard

                        // 3. Portion Adjustment Slider
                        portionAdjustmentCard

                        // 4. Live Nutrition Preview
                        nutritionPreviewCard

                        // 5. Optional Notes
                        notesCard

                        // 6. Planned vs Diary Notice
                        plannedNoticeCard
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Lên thực đơn tuần")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Xác nhận") {
                        let cleanNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onConfirm(
                            suggestion,
                            selectedDate,
                            selectedCategory,
                            servingMultiplier,
                            cleanNotes.isEmpty ? nil : cleanNotes
                        )
                        dismiss()
                    }
                    .font(AppTypography.bodyBold)
                    .foregroundColor(AppColors.forestGreen)
                    .accessibilityIdentifier("confirm_add_to_plan_button")
                }
            }
        }
    }

    // MARK: - Subviews
    private var dishSummaryCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.mintSurface)
                    .frame(width: 44, height: 44)
                Image(systemName: suggestion.foodSource.systemIcon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.forestGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.displayName)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 4) {
                    Text(suggestion.dishCategory)
                    Text("•")
                    Text(suggestion.suggestedServing)
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    private var scheduleTargetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Thời gian & Bữa ăn")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            // Date Picker
            DatePicker(
                "Ngày lên lịch",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .environment(\.locale, Locale(identifier: "vi_VN"))
            .font(.system(size: 14))

            Divider()

            // Meal Category Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Chọn bữa ăn")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: 6) {
                    ForEach(PlannedMealCategory.allCases) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: cat.systemIcon)
                                    .font(.system(size: 13))
                                Text(cat.vietnameseName)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(selectedCategory == cat ? .white : AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedCategory == cat ? AppColors.forestGreen : Color(red: 0.95, green: 0.97, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var portionAdjustmentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Khẩu phần ăn")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(multiplierDescription)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.forestGreen)
            }

            Slider(value: $servingMultiplier, in: 0.5...2.5, step: 0.25)
                .tint(AppColors.forestGreen)

            HStack {
                Text("0.5x (Ít hơn)")
                Spacer()
                Text("1.0x (Chuẩn)")
                Spacer()
                Text("2.5x (Nhiều hơn)")
            }
            .font(.system(size: 10))
            .foregroundColor(AppColors.textTertiary)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var multiplierDescription: String {
        let grams = Int(suggestion.suggestedServingGrams * servingMultiplier)
        if servingMultiplier == 1.0 {
            return "1.0x chuẩn (\(grams)g)"
        } else {
            return String(format: "%.2fx (~%dg)", servingMultiplier, grams)
        }
    }

    private var nutritionPreviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dinh dưỡng dự tính khẩu phần này")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            let cal = suggestion.availableNutritionEstimate.calories * servingMultiplier
            let pro = suggestion.availableNutritionEstimate.proteinGrams * servingMultiplier
            let carb = suggestion.availableNutritionEstimate.carbGrams * servingMultiplier
            let fat = suggestion.availableNutritionEstimate.fatGrams * servingMultiplier

            HStack(spacing: 8) {
                PlannedMacroTile(label: "Năng lượng", value: "\(Int(cal)) kcal", color: AppColors.forestGreen)
                PlannedMacroTile(label: "Đạm", value: "\(Int(pro))g", color: AppColors.proteinBlue)
                PlannedMacroTile(label: "Carb", value: "\(Int(carb))g", color: AppColors.carbOrange)
                PlannedMacroTile(label: "Béo", value: "\(Int(fat))g", color: AppColors.fatRed)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ghi chú bữa ăn (Tùy chọn)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            TextField("Ví dụ: Ăn kèm nhiều rau xanh, ít nước béo...", text: $notesText)
                .font(.system(size: 13))
                .padding(10)
                .background(Color(red: 0.97, green: 0.98, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var plannedNoticeCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(AppColors.forestGreen)

            Text("Món ăn sẽ xuất hiện trong Kế hoạch thực đơn tuần. Lượng calo và đa lượng sẽ CHỈ được tính vào nhật ký thực tế khi bạn xác nhận 'Đã ăn'.")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(2)
        }
        .padding(12)
        .background(AppColors.mintSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct PlannedMacroTile: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(red: 0.96, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

