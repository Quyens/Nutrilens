//
//  LogFromExplorerSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Seamless meal logging from Food Explorer into SwiftData.
//

import SwiftUI

public struct LogFromExplorerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    public let dish: VietnameseDishProfile
    public let scaledNutrition: ScaledNutrition

    @State private var selectedMealType: MealType
    @State private var mealDate: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving: Bool = false
    @State private var saveSuccess: Bool = false
    @State private var errorMessage: String? = nil

    public init(
        dish: VietnameseDishProfile,
        scaledNutrition: ScaledNutrition,
        defaultMealType: MealType = .lunch
    ) {
        self.dish = dish
        self.scaledNutrition = scaledNutrition
        self._selectedMealType = State(initialValue: defaultMealType)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Dish summary card
                        HStack(spacing: AppSpacing.md) {
                            Image(dish.assetImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text(dish.vietnameseName)
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineLimit(1)

                                Text(dish.englishName)
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(1)

                                HStack(spacing: AppSpacing.xs) {
                                    Text("\(Int(scaledNutrition.servingGrams))g")
                                        .font(AppTypography.captionBold)
                                        .foregroundColor(AppColors.primaryGreen)

                                    Text("•")
                                        .foregroundColor(AppColors.textTertiary)

                                    Text("\(Int(scaledNutrition.calories)) kcal")
                                        .font(AppTypography.captionBold)
                                        .foregroundColor(AppColors.primaryGreen)
                                }
                                .padding(.top, 2)
                            }

                            Spacer()
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )

                        // Meal Type Selection
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Thời điểm dùng bữa")
                                .font(AppTypography.sectionTitle)
                                .foregroundColor(AppColors.textPrimary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                                ForEach(MealType.allCases) { type in
                                    Button(action: {
                                        selectedMealType = type
                                    }) {
                                        HStack(spacing: AppSpacing.xs) {
                                            Image(systemName: type.systemIcon)
                                                .font(.system(size: 15))
                                                .foregroundColor(selectedMealType == type ? AppColors.primaryGreen : AppColors.textSecondary)

                                            Text(type.vietnameseName)
                                                .font(AppTypography.subheadlineBold)
                                                .foregroundColor(selectedMealType == type ? AppColors.textPrimary : AppColors.textSecondary)

                                            Spacer()

                                            if selectedMealType == type {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.primaryGreen)
                                            }
                                        }
                                        .padding(.horizontal, AppSpacing.md)
                                        .padding(.vertical, 14)
                                        .background(selectedMealType == type ? AppColors.mintSurface : AppColors.surfacePrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                                .stroke(selectedMealType == type ? AppColors.primaryGreen : AppColors.border, lineWidth: selectedMealType == type ? 1.5 : 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Time Picker Card
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Thời gian")
                                .font(AppTypography.sectionTitle)
                                .foregroundColor(AppColors.textPrimary)

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(AppColors.primaryGreen)
                                    .font(.system(size: 16))

                                DatePicker("", selection: $mealDate, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()

                                Spacer()
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surfacePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }

                        // Scaled Nutrition Summary
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Dinh dưỡng ghi nhận")
                                .font(AppTypography.sectionTitle)
                                .foregroundColor(AppColors.textPrimary)

                            HStack(spacing: AppSpacing.sm) {
                                MacroPill(title: "Calo", value: "\(Int(scaledNutrition.calories))", unit: "kcal", color: AppColors.primaryGreen)
                                MacroPill(title: "Đạm", value: String(format: "%.1f", scaledNutrition.protein), unit: "g", color: AppColors.proteinBlue)
                                MacroPill(title: "Carbs", value: String(format: "%.1f", scaledNutrition.carbs), unit: "g", color: AppColors.carbsOrange)
                                MacroPill(title: "Béo", value: String(format: "%.1f", scaledNutrition.fat), unit: "g", color: AppColors.fatCoral)
                            }
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Submit Button
                        Button(action: saveMealToDiary) {
                            HStack(spacing: AppSpacing.xs) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else if saveSuccess {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Đã lưu vào nhật ký!")
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Xác nhận ghi vào nhật ký")
                                }
                            }
                            .font(AppTypography.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(saveSuccess ? Color(hex: "278B53") : AppColors.primaryGreen)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isSaving || saveSuccess)
                        .accessibilityIdentifier("button_confirm_log_meal")
                        .padding(.top, AppSpacing.sm)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.lg)
                }
            }
            .navigationTitle("Ghi vào nhật ký")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private func saveMealToDiary() {
        isSaving = true
        errorMessage = nil

        let foodItem = FoodItem(
            name: dish.englishName,
            vietnameseName: dish.vietnameseName,
            confidence: 1.0,
            servingSizeGrams: scaledNutrition.servingGrams,
            calories: scaledNutrition.calories,
            proteinGrams: scaledNutrition.protein,
            carbGrams: scaledNutrition.carbs,
            fatGrams: scaledNutrition.fat,
            fiberGrams: scaledNutrition.fiber
        )

        let record = MealRecord(
            id: UUID(),
            timestamp: mealDate,
            mealType: selectedMealType,
            items: [foodItem],
            notes: "Ghi từ Thư viện món ăn NutriLens"
        )

        Task {
            do {
                try await environment.logMealUseCase.execute(meal: record)
                isSaving = false
                saveSuccess = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                try? await Task.sleep(nanoseconds: 700_000_000)
                dismiss()
            } catch {
                isSaving = false
                errorMessage = "Không thể lưu bữa ăn: \(error.localizedDescription)"
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

private struct MacroPill: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(unit)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
