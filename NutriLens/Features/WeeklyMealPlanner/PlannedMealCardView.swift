//
//  PlannedMealCardView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Botanical display card for a planned meal.
//

import SwiftUI

public struct PlannedMealCardView: View {
    let meal: PlannedMeal
    let onSelect: () -> Void
    let onLogToDiary: () -> Void
    let onMarkSkipped: () -> Void
    let onRestore: () -> Void
    let onDuplicateToTomorrow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    public init(
        meal: PlannedMeal,
        onSelect: @escaping () -> Void,
        onLogToDiary: @escaping () -> Void,
        onMarkSkipped: @escaping () -> Void,
        onRestore: @escaping () -> Void,
        onDuplicateToTomorrow: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.meal = meal
        self.onSelect = onSelect
        self.onLogToDiary = onLogToDiary
        self.onMarkSkipped = onMarkSkipped
        self.onRestore = onRestore
        self.onDuplicateToTomorrow = onDuplicateToTomorrow
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Card Top Row: Category, Status & More Menu
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: meal.mealCategory.systemIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)

                    Text(meal.mealCategory.vietnameseName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                // Status Badge
                StatusBadge(status: meal.status)

                // More Menu
                Menu {
                    if meal.status == .planned {
                        Button {
                            onLogToDiary()
                        } label: {
                            Label("Đã ăn — Ghi vào nhật ký", systemImage: "checkmark.circle")
                        }

                        Button {
                            onMarkSkipped()
                        } label: {
                            Label("Bỏ qua bữa này", systemImage: "slash.circle")
                        }

                        Button {
                            onDuplicateToTomorrow()
                        } label: {
                            Label("Nhân bản sang ngày mai", systemImage: "doc.on.doc")
                        }

                        Button {
                            onEdit()
                        } label: {
                            Label("Chỉnh sửa kế hoạch", systemImage: "pencil")
                        }
                    } else {
                        Button {
                            onRestore()
                        } label: {
                            Label("Khôi phục kế hoạch", systemImage: "arrow.uturn.backward")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Xóa bữa ăn", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(6)
                        .contentShape(Rectangle())
                }
            }

            // Food Items List
            VStack(alignment: .leading, spacing: 6) {
                ForEach(meal.foodItems) { item in
                    PlannedFoodItemCardRow(item: item)
                }
            }
            .padding(.vertical, 2)

            // Optional Notes
            if let notes = meal.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 12))
                    .italic()
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Divider()
                .background(Color(red: 0.90, green: 0.93, blue: 0.91))

            // Footer: Nutrition Totals & Primary Action
            HStack(alignment: .center) {
                // Nutrition Totals
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(Int(meal.totalCalories))")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                        Text("kcal")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    MacroMiniItem(title: "Đạm", value: "\(Int(meal.totalProteinGrams))g", color: AppColors.proteinBlue)
                    MacroMiniItem(title: "Carb", value: "\(Int(meal.totalCarbGrams))g", color: AppColors.carbOrange)
                    MacroMiniItem(title: "Béo", value: "\(Int(meal.totalFatGrams))g", color: AppColors.fatRed)
                }

                Spacer()

                // If planned, prominent "Đã ăn" button
                if meal.status == .planned {
                    Button(action: onLogToDiary) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("Đã ăn")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primaryGreen, AppColors.forestGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("log_meal_\(meal.id.uuidString)")
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
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

private struct StatusBadge: View {
    let status: PlannedMealStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemIcon)
                .font(.system(size: 10, weight: .bold))

            Text(status.vietnameseTitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .planned:
            return AppColors.mintSurface
        case .completed:
            return AppColors.primaryGreen.opacity(0.12)
        case .skipped:
            return Color.orange.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .planned:
            return AppColors.primaryGreen
        case .completed:
            return AppColors.primaryGreen
        case .skipped:
            return Color.orange
        }
    }
}

private struct MacroMiniItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

private struct PlannedFoodItemCardRow: View {
    let item: PlannedFoodItem

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppColors.primaryGreen.opacity(0.8))
                .frame(width: 5, height: 5)

            Text(item.displayName)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Spacer()

            Text("\(Int(item.quantity)) \(item.servingUnit)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            Text("• \(Int(item.nutritionSnapshot.calories)) kcal")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}


