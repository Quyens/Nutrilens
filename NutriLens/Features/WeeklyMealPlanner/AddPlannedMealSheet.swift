//
//  AddPlannedMealSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Sheet to add or edit a planned meal in the Weekly Meal Planner.
//

import SwiftUI

public struct AddPlannedMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    let initialDate: Date
    let initialCategory: PlannedMealCategory
    let existingMeal: PlannedMeal?
    let onSave: (PlannedMeal) -> Void

    @State private var scheduledDate: Date
    @State private var selectedCategory: PlannedMealCategory
    @State private var foodItems: [PlannedFoodItem] = []
    @State private var notes: String = ""
    @State private var isShowingFoodPicker: Bool = false

    public init(
        initialDate: Date,
        initialCategory: PlannedMealCategory = .lunch,
        existingMeal: PlannedMeal? = nil,
        onSave: @escaping (PlannedMeal) -> Void
    ) {
        self.initialDate = initialDate
        self.initialCategory = initialCategory
        self.existingMeal = existingMeal
        self.onSave = onSave

        _scheduledDate = State(initialValue: existingMeal?.scheduledDate ?? initialDate)
        _selectedCategory = State(initialValue: existingMeal?.mealCategory ?? initialCategory)
        _foodItems = State(initialValue: existingMeal?.foodItems ?? [])
        _notes = State(initialValue: existingMeal?.notes ?? "")
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Date & Category Pickers
                        scheduleSection

                        // Staged Food Items Section
                        stagedFoodsSection

                        // Nutrition Preview Card
                        nutritionPreviewSection

                        // Notes Section
                        notesSection

                        // Save Button
                        saveButton
                    }
                    .padding(AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle(existingMeal == nil ? "Thêm vào thực đơn" : "Sửa kế hoạch bữa ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .sheet(isPresented: $isShowingFoodPicker) {
                PlannedFoodSourcePickerSheet { item in
                    foodItems.append(item)
                }
            }
        }
    }

    // MARK: - Schedule Section
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thời gian & Phân loại")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            // Date Picker
            DatePicker(
                "Ngày áp dụng",
                selection: $scheduledDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(AppColors.primaryGreen)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
            )

            // Category Segment
            HStack(spacing: 6) {
                ForEach(PlannedMealCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 11))
                            Text(category.vietnameseName)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(selectedCategory == category ? .white : AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? AppColors.primaryGreen : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(selectedCategory == category ? Color.clear : Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Staged Foods Section
    private var stagedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Món ăn đã chọn (\(foodItems.count))")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button {
                    isShowingFoodPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Thêm món")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryGreen)
                }
            }

            if foodItems.isEmpty {
                Button {
                    isShowingFoodPicker = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                        Text("Chưa chọn món nào. Nhấn để chọn từ cơ sở dữ liệu.")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.4))
                    )
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(foodItems.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.displayName)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)

                                Text("\(Int(item.quantity)) \(item.servingUnit) • \(Int(item.nutritionSnapshot.calories)) kcal")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()

                            Button {
                                foodItems.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(8)
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Nutrition Preview Section
    private var totalNutrition: PlannedNutritionSnapshot {
        foodItems.reduce(.zero) { $0 + $1.nutritionSnapshot }
    }

    private var nutritionPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dự tính dinh dưỡng bữa ăn")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 10) {
                MacroBox(title: "Năng lượng", value: "\(Int(totalNutrition.calories))", unit: "kcal", color: AppColors.primaryGreen)
                MacroBox(title: "Chất đạm", value: String(format: "%.1f", totalNutrition.proteinGrams), unit: "g", color: AppColors.proteinBlue)
                MacroBox(title: "Tinh bột", value: String(format: "%.1f", totalNutrition.carbGrams), unit: "g", color: AppColors.carbOrange)
                MacroBox(title: "Chất béo", value: String(format: "%.1f", totalNutrition.fatGrams), unit: "g", color: AppColors.fatRed)
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ghi chú kế hoạch (tùy chọn)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            TextField("Ví dụ: Mua nguyên liệu lúc chiều, ăn ít cơm...", text: $notes, axis: .vertical)
                .lineLimit(2...4)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
                )
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveAction) {
            Text(existingMeal == nil ? "Lưu vào kế hoạch" : "Cập nhật bữa ăn")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    foodItems.isEmpty ?
                    LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [AppColors.primaryGreen, AppColors.forestGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        }
        .disabled(foodItems.isEmpty)
        .accessibilityIdentifier("save_planned_meal_button")
    }

    private func saveAction() {
        let mealToSave: PlannedMeal
        if let existing = existingMeal {
            mealToSave = PlannedMeal(
                id: existing.id,
                scheduledDate: scheduledDate,
                mealCategory: selectedCategory,
                foodItems: foodItems,
                notes: notes.isEmpty ? nil : notes,
                status: existing.status,
                linkedDiaryRecordId: existing.linkedDiaryRecordId,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        } else {
            mealToSave = PlannedMeal(
                id: UUID(),
                scheduledDate: scheduledDate,
                mealCategory: selectedCategory,
                foodItems: foodItems,
                notes: notes.isEmpty ? nil : notes,
                status: .planned,
                linkedDiaryRecordId: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        onSave(mealToSave)
        dismiss()
    }
}

private struct MacroBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
        )
    }
}

