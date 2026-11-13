//
//  LogPlannedMealConfirmationSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Confirmation & portion-correction sheet when logging a planned meal to the actual Meal Diary.
//

import SwiftUI

public struct LogPlannedMealConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let plannedMeal: PlannedMeal
    let onConfirm: ([FoodItem], Date, MealType, String?) -> Void

    @State private var loggedDate: Date = Date()
    @State private var selectedMealType: MealType
    @State private var items: [EditablePlannedItem] = []
    @State private var notes: String

    public init(
        plannedMeal: PlannedMeal,
        onConfirm: @escaping ([FoodItem], Date, MealType, String?) -> Void
    ) {
        self.plannedMeal = plannedMeal
        self.onConfirm = onConfirm

        _selectedMealType = State(initialValue: plannedMeal.mealCategory.toMealType)
        _notes = State(initialValue: plannedMeal.notes ?? "")

        let initialEditable = plannedMeal.foodItems.map {
            EditablePlannedItem(
                id: $0.id,
                displayName: $0.displayName,
                quantity: $0.quantity,
                servingUnit: $0.servingUnit,
                baseItem: $0
            )
        }
        _items = State(initialValue: initialEditable)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Header description
                        headerBanner

                        // Meal Type & Consumption Time
                        timeAndTypeSection

                        // Portions Correction Section
                        itemsSection

                        // Calculated Actual Nutrition
                        nutritionSummarySection

                        // Optional Notes
                        notesSection

                        // Confirm & Log CTA
                        confirmButton
                    }
                    .padding(AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Ghi vào nhật ký")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Header Banner
    private var headerBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 24))
                .foregroundColor(AppColors.primaryGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text("Xác nhận đã dùng bữa")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Bạn có thể điều chỉnh lượng thực tế đã ăn trước khi lưu vào nhật ký.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(12)
        .background(AppColors.mintSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Time and Type Section
    private var timeAndTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Thời gian & Phân loại nhật ký")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            DatePicker(
                "Thời gian ăn",
                selection: $loggedDate,
                displayedComponents: [.date, .hourAndMinute]
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

            // Meal Type Segment
            HStack(spacing: 6) {
                ForEach(MealType.allCases) { type in
                    Button {
                        selectedMealType = type
                    } label: {
                        Text(type.vietnameseName)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(selectedMealType == type ? .white : AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedMealType == type ? AppColors.primaryGreen : Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(selectedMealType == type ? Color.clear : Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Items Section
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lượng thức ăn thực tế (\(items.count))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 8) {
                ForEach($items) { $item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.displayName)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Text("\(Int(item.quantity)) \(item.servingUnit)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primaryGreen)
                        }

                        // Stepper row for adjusting quantity
                        HStack(spacing: 12) {
                            Text("Điều chỉnh:")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)

                            Button {
                                if item.quantity > 20 { item.quantity -= 10 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primaryGreen)
                            }

                            Slider(value: $item.quantity, in: 20...1000, step: 10)
                                .tint(AppColors.primaryGreen)

                            Button {
                                if item.quantity < 1000 { item.quantity += 10 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primaryGreen)
                            }
                        }

                        // Calculated Macro for item
                        let snap = item.scaledSnapshot
                        HStack(spacing: 8) {
                            Text("\(Int(snap.calories)) kcal")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.primaryGreen)
                            Text("• P: \(String(format: "%.1f", snap.proteinGrams))g")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.proteinBlue)
                            Text("• C: \(String(format: "%.1f", snap.carbGrams))g")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.carbOrange)
                            Text("• F: \(String(format: "%.1f", snap.fatGrams))g")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.fatRed)
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

    // MARK: - Nutrition Summary Section
    private var totalCalories: Double {
        items.reduce(0) { $0 + $1.scaledSnapshot.calories }
    }
    private var totalProtein: Double {
        items.reduce(0) { $0 + $1.scaledSnapshot.proteinGrams }
    }
    private var totalCarb: Double {
        items.reduce(0) { $0 + $1.scaledSnapshot.carbGrams }
    }
    private var totalFat: Double {
        items.reduce(0) { $0 + $1.scaledSnapshot.fatGrams }
    }

    private var nutritionSummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tổng dinh dưỡng nạp thực tế")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 8) {
                SummaryBox(title: "Năng lượng", value: "\(Int(totalCalories)) kcal", color: AppColors.primaryGreen)
                SummaryBox(title: "Đạm", value: "\(Int(totalProtein))g", color: AppColors.proteinBlue)
                SummaryBox(title: "Carb", value: "\(Int(totalCarb))g", color: AppColors.carbOrange)
                SummaryBox(title: "Béo", value: "\(Int(totalFat))g", color: AppColors.fatRed)
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ghi chú bữa ăn thực tế (tùy chọn)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            TextField("Ví dụ: Ăn hết bát, thêm rau sống...", text: $notes)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
                )
        }
    }

    // MARK: - Confirm Button
    private var confirmButton: some View {
        Button(action: {
            let foodItems = items.map { $0.toFoodItem() }
            onConfirm(foodItems, loggedDate, selectedMealType, notes.isEmpty ? nil : notes)
            dismiss()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                Text("Xác nhận & Lưu vào nhật ký")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.forestGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        }
        .accessibilityIdentifier("confirm_log_to_diary_button")
    }
}

private struct SummaryBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(color)
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

private struct EditablePlannedItem: Identifiable {
    let id: UUID
    var displayName: String
    var quantity: Double
    var servingUnit: String
    let baseItem: PlannedFoodItem

    var scaledSnapshot: PlannedNutritionSnapshot {
        guard baseItem.quantity > 0 else { return baseItem.nutritionSnapshot }
        let factor = quantity / baseItem.quantity
        return PlannedNutritionSnapshot(
            calories: (baseItem.nutritionSnapshot.calories * factor).rounded(),
            proteinGrams: ((baseItem.nutritionSnapshot.proteinGrams * factor) * 10).rounded() / 10,
            carbGrams: ((baseItem.nutritionSnapshot.carbGrams * factor) * 10).rounded() / 10,
            fatGrams: ((baseItem.nutritionSnapshot.fatGrams * factor) * 10).rounded() / 10,
            fiberGrams: ((baseItem.nutritionSnapshot.fiberGrams * factor) * 10).rounded() / 10
        )
    }

    func toFoodItem() -> FoodItem {
        let snap = scaledSnapshot
        return FoodItem(
            id: UUID(),
            name: displayName,
            vietnameseName: displayName,
            confidence: 1.0,
            servingSizeGrams: quantity,
            calories: snap.calories,
            proteinGrams: snap.proteinGrams,
            carbGrams: snap.carbGrams,
            fatGrams: snap.fatGrams,
            fiberGrams: snap.fiberGrams
        )
    }
}

