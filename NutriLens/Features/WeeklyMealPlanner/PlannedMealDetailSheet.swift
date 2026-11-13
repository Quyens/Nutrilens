//
//  PlannedMealDetailSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Detailed visual inspection sheet for a planned meal with management actions.
//

import SwiftUI

public struct PlannedMealDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let meal: PlannedMeal
    let onLogToDiary: () -> Void
    let onMarkSkipped: () -> Void
    let onRestore: () -> Void
    let onDuplicateToTomorrow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    public init(
        meal: PlannedMeal,
        onLogToDiary: @escaping () -> Void,
        onMarkSkipped: @escaping () -> Void,
        onRestore: @escaping () -> Void,
        onDuplicateToTomorrow: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.meal = meal
        self.onLogToDiary = onLogToDiary
        self.onMarkSkipped = onMarkSkipped
        self.onRestore = onRestore
        self.onDuplicateToTomorrow = onDuplicateToTomorrow
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Header Category Card
                        headerCard

                        // Macro Totals Card
                        macroTotalsCard

                        // Food Items List Card
                        foodItemsCard

                        // Notes if any
                        if let notes = meal.notes, !notes.isEmpty {
                            notesCard(notes)
                        }

                        // Actions Section
                        actionsSection
                    }
                    .padding(AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Chi tiết kế hoạch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.mintSurface)
                    .frame(width: 48, height: 48)

                Image(systemName: meal.mealCategory.systemIcon)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(meal.mealCategory.vietnameseName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                let formatter = DateFormatter()
                let _ = formatter.locale = Locale(identifier: "vi_VN")
                let _ = formatter.dateFormat = "EEEE, dd/MM/yyyy"
                Text(formatter.string(from: meal.scheduledDate).capitalized)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // Status Indicator
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: meal.status.systemIcon)
                        .font(.system(size: 10, weight: .bold))
                    Text(meal.status.vietnameseTitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusBackground)
                .foregroundColor(statusForeground)
                .clipShape(Capsule())

                if let linkedId = meal.linkedDiaryRecordId {
                    Text("Đã liên kết nhật ký")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
    }

    private var statusBackground: Color {
        switch meal.status {
        case .planned: return AppColors.mintSurface
        case .completed: return AppColors.primaryGreen.opacity(0.12)
        case .skipped: return Color.orange.opacity(0.12)
        }
    }

    private var statusForeground: Color {
        switch meal.status {
        case .planned: return AppColors.primaryGreen
        case .completed: return AppColors.primaryGreen
        case .skipped: return Color.orange
        }
    }

    // MARK: - Macro Totals Card
    private var macroTotalsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tổng quan dinh dưỡng kế hoạch")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(meal.totalCalories))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                    Text("kcal ước tính")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    MacroColumn(title: "Chất đạm", value: "\(Int(meal.totalProteinGrams))g", color: AppColors.proteinBlue)
                    MacroColumn(title: "Tinh bột", value: "\(Int(meal.totalCarbGrams))g", color: AppColors.carbOrange)
                    MacroColumn(title: "Chất béo", value: "\(Int(meal.totalFatGrams))g", color: AppColors.fatRed)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
    }

    // MARK: - Food Items Card
    private var foodItemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Danh sách món ăn (\(meal.foodItems.count))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 10) {
                ForEach(meal.foodItems) { item in
                    FoodItemDetailRow(item: item)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
    }

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ghi chú")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text(notes)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 10) {
            if meal.status == .planned {
                // Main CTA: Log to Diary
                Button(action: {
                    dismiss()
                    onLogToDiary()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Đã ăn — Ghi vào nhật ký")
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

                // Secondary CTA: Skip
                Button(action: {
                    onMarkSkipped()
                    dismiss()
                }) {
                    Text("Bỏ qua bữa này")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                }
            } else {
                // Restore status
                Button(action: {
                    onRestore()
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Khôi phục trạng thái Kế hoạch")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.mintSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                }
            }

            // Duplicate & Edit Row
            HStack(spacing: 10) {
                Button(action: {
                    onDuplicateToTomorrow()
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Nhân bản sang mai")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                    )
                }

                Button(action: {
                    dismiss()
                    onEdit()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Chỉnh sửa")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                    )
                }
            }

            // Delete
            Button(role: .destructive, action: {
                onDelete()
                dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Xóa kế hoạch bữa ăn")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
            }
        }
        .padding(.top, 4)
    }
}

private struct MacroColumn: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

private struct FoodItemDetailRow: View {
    let item: PlannedFoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(Int(item.quantity)) \(item.servingUnit)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.primaryGreen)
            }

            let snap = item.nutritionSnapshot
            HStack(spacing: 8) {
                Text("\(Int(snap.calories)) kcal")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text("•")
                    .foregroundColor(AppColors.textSecondary)
                Text("P: \(String(format: "%.1f", snap.proteinGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.proteinBlue)
                Text("C: \(String(format: "%.1f", snap.carbGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.carbsOrange)
                Text("F: \(String(format: "%.1f", snap.fatGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.fatCoral)
            }
        }
        .padding(10)
        .background(Color(red: 0.96, green: 0.98, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}


