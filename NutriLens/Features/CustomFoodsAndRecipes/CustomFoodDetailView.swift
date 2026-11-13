//
//  CustomFoodDetailView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Custom Food Detail View with dynamic portion adjustment,
//  micronutrient breakdown, edit, delete, and diary integration.
//

import SwiftUI

public struct CustomFoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    @State private var currentFood: CustomFood
    private let onFoodDeleted: () -> Void
    private let onQuickLog: (CustomFood) -> Void

    // Interactive Portion State
    @State private var currentGrams: Double
    @State private var isPresentingEdit: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var selectedMealType: MealType = .lunch
    @State private var isLogging: Bool = false
    @State private var logSuccessToast: Bool = false

    public init(
        food: CustomFood,
        onFoodDeleted: @escaping () -> Void = {},
        onQuickLog: @escaping (CustomFood) -> Void = { _ in }
    ) {
        _currentFood = State(initialValue: food)
        _currentGrams = State(initialValue: food.servingGrams)
        self.onFoodDeleted = onFoodDeleted
        self.onQuickLog = onQuickLog
    }

    private var scaledFood: CustomFood {
        currentFood.scaled(to: currentGrams)
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Hero Card
                        heroCard

                        // Portion Adjustment Card
                        portionAdjustmentCard

                        // Macro Breakdown Card
                        macroBreakdownCard

                        // Micronutrients Card (if available)
                        if let micro = scaledFood.micronutrients {
                            micronutrientsCard(micro)
                        }

                        // Notes (if available)
                        if let notes = currentFood.notes, !notes.isEmpty {
                            notesCard(notes)
                        }

                        // Action Buttons Card (Edit & Delete)
                        managementActionsCard

                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                }

                // Bottom floating log button
                VStack {
                    Spacer()
                    bottomFloatingLogBar
                }
            }
            .navigationTitle("Chi tiết món ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: currentFood.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(currentFood.isFavorite ? Color(hex: "E04F5F") : AppColors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $isPresentingEdit) {
                CreateEditCustomFoodView(existingFood: currentFood) { updated in
                    self.currentFood = updated
                    self.currentGrams = updated.servingGrams
                }
            }
            .alert("Xác nhận xóa món", isPresented: $showDeleteConfirmation) {
                Button("Hủy", role: .cancel) {}
                Button("Xóa vĩnh viễn", role: .destructive) {
                    deleteFood()
                }
            } message: {
                Text("Bạn có chắc chắn muốn xóa món \"\(currentFood.name)\"? Hành động này không thể hoàn tác.")
            }
        }
    }

    // MARK: - Subviews
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(currentFood.category)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())

                if let brand = currentFood.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }

            Text(currentFood.name)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(AppColors.textPrimary)

            Text("Khẩu phần chuẩn: 1 \(currentFood.servingUnit) = \(Int(currentFood.servingGrams))g")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var portionAdjustmentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Điều chỉnh trọng lượng")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(Int(currentGrams))g")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryGreen)
            }

            // Quick Preset Buttons
            HStack(spacing: 8) {
                quickPortionPill("100g", grams: 100)
                quickPortionPill("1 \(currentFood.servingUnit)", grams: currentFood.servingGrams)
                quickPortionPill("1.5x", grams: currentFood.servingGrams * 1.5)
                quickPortionPill("2x", grams: currentFood.servingGrams * 2.0)
            }

            // Slider
            Slider(value: $currentGrams, in: 20...1000, step: 10)
                .tint(AppColors.primaryGreen)
        }
        .padding(18)
        .background(cardBackground)
    }

    private func quickPortionPill(_ title: String, grams: Double) -> some View {
        let isSelected = abs(currentGrams - grams) < 2
        return Button {
            withAnimation(.spring(response: 0.3)) {
                currentGrams = grams
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? AnyView(AppColors.primaryGreen) : AnyView(AppColors.surfaceSecondary))
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var macroBreakdownCard: some View {
        VStack(spacing: 16) {
            // Big Calories Display
            VStack(spacing: 4) {
                Text("NĂNG LƯỢNG")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(scaledFood.caloriesPerServing))")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                    Text("kcal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }

                Text("Tương đương \(Int(currentFood.caloriesPer100g)) kcal / 100g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)

            Divider()

            // 4 Macro Pills
            HStack(spacing: 8) {
                macroItem(title: "Đạm", value: String(format: "%.1fg", scaledFood.proteinGrams), color: Color(hex: "2B6CB0"))
                macroItem(title: "Carbs", value: String(format: "%.1fg", scaledFood.carbGrams), color: Color(hex: "C05621"))
                macroItem(title: "Béo", value: String(format: "%.1fg", scaledFood.fatGrams), color: Color(hex: "C53030"))
                macroItem(title: "Xơ", value: String(format: "%.1fg", scaledFood.fiberGrams), color: Color(hex: "27AE60"))
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private func macroItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func micronutrientsCard(_ micro: MicronutrientProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vi chất dinh dưỡng")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                if let v = micro.sodiumMg {
                    microRow(name: "Natri", value: "\(Int(v)) mg")
                }
                if let v = micro.potassiumMg {
                    microRow(name: "Kali", value: "\(Int(v)) mg")
                }
                if let v = micro.calciumMg {
                    microRow(name: "Canxi", value: "\(Int(v)) mg")
                }
                if let v = micro.ironMg {
                    microRow(name: "Sắt", value: String(format: "%.1f mg", v))
                }
                if let v = micro.vitaminAMcg {
                    microRow(name: "Vitamin A", value: "\(Int(v)) mcg")
                }
                if let v = micro.vitaminCMg {
                    microRow(name: "Vitamin C", value: String(format: "%.1f mg", v))
                }
                if let v = micro.sugarGrams {
                    microRow(name: "Đường", value: String(format: "%.1f g", v))
                }
                if let v = micro.cholesterolMg {
                    microRow(name: "Cholesterol", value: "\(Int(v)) mg")
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private func microRow(name: String, value: String) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(8)
        .background(AppColors.surfaceSecondary.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ghi chú")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(notes)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
    }

    private var managementActionsCard: some View {
        VStack(spacing: 12) {
            Button {
                isPresentingEdit = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Chỉnh sửa thông tin món ăn")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Xóa món ăn này")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "FFF4F2"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(18)
        .background(cardBackground)
    }

    private var bottomFloatingLogBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                Picker("Bữa ăn", selection: $selectedMealType) {
                    Text("Sáng").tag(MealType.breakfast)
                    Text("Trưa").tag(MealType.lunch)
                    Text("Tối").tag(MealType.dinner)
                    Text("Phụ").tag(MealType.snack)
                }
                .pickerStyle(.menu)
                .tint(AppColors.primaryGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    logCurrentFood()
                } label: {
                    HStack {
                        if isLogging {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                            Text("Ghi vào nhật ký (\(Int(scaledFood.caloriesPerServing)) kcal)")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(isLogging)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }

    // MARK: - Actions
    private func toggleFavorite() {
        var updated = currentFood
        updated.isFavorite.toggle()
        Task {
            do {
                try await environment.saveCustomFoodUseCase.execute(updated)
                self.currentFood = updated
            } catch {}
        }
    }

    private func deleteFood() {
        Task {
            do {
                try await environment.deleteCustomFoodUseCase.execute(id: currentFood.id)
                onFoodDeleted()
                dismiss()
            } catch {}
        }
    }

    private func logCurrentFood() {
        isLogging = true
        let snapshot = scaledFood.toFoodItem()
        let meal = MealRecord(
            timestamp: Date(),
            mealType: selectedMealType,
            items: [snapshot],
            notes: "Ghi từ thư viện món cá nhân"
        )
        Task {
            do {
                try await environment.logMealUseCase.execute(meal: meal)
                isLogging = false
                NotificationCenter.default.post(name: NSNotification.Name("NutriLensMealDiaryChanged"), object: nil)
                onQuickLog(scaledFood)
                dismiss()
            } catch {
                isLogging = false
            }
        }
    }
}
