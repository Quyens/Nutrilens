//
//  RecipeDetailView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Recipe Detail View with dynamic servings adjustment,
//  live ingredient scaling, instructions, edit, delete, and diary logging.
//

import SwiftUI

public struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    @State private var currentRecipe: Recipe
    private let onRecipeDeleted: () -> Void
    private let onQuickLog: (Recipe, Double) -> Void

    // Dynamic Servings Scaling
    @State private var displayedServings: Double
    @State private var isPresentingEdit: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var selectedMealType: MealType = .lunch
    @State private var isLogging: Bool = false

    public init(
        recipe: Recipe,
        onRecipeDeleted: @escaping () -> Void = {},
        onQuickLog: @escaping (Recipe, Double) -> Void = { _, _ in }
    ) {
        _currentRecipe = State(initialValue: recipe)
        _displayedServings = State(initialValue: Double(recipe.servings))
        self.onRecipeDeleted = onRecipeDeleted
        self.onQuickLog = onQuickLog
    }

    private var perServingNutrition: RecipeNutritionSnapshot {
        currentRecipe.perServingNutrition
    }

    private var scaledNutritionForDisplayed: RecipeNutritionSnapshot {
        currentRecipe.scaledNutrition(forServings: displayedServings)
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

                        // Servings Scaler Card
                        servingsScalerCard

                        // Macro Breakdown Card
                        macroBreakdownCard

                        // Ingredients List Card
                        ingredientsCard

                        // Cooking Instructions Card
                        instructionsCard

                        // Notes Card
                        if let notes = currentRecipe.notes, !notes.isEmpty {
                            notesCard(notes)
                        }

                        // Management Actions Card (Edit & Delete)
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
            .navigationTitle("Chi tiết công thức")
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
                        Image(systemName: currentRecipe.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(currentRecipe.isFavorite ? Color(hex: "E04F5F") : AppColors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $isPresentingEdit) {
                CreateEditRecipeView(existingRecipe: currentRecipe) { updated in
                    self.currentRecipe = updated
                    self.displayedServings = Double(updated.servings)
                }
            }
            .alert("Xác nhận xóa công thức", isPresented: $showDeleteConfirmation) {
                Button("Hủy", role: .cancel) {}
                Button("Xóa vĩnh viễn", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Bạn có chắc chắn muốn xóa công thức \"\(currentRecipe.name)\"?")
            }
        }
    }

    // MARK: - Subviews
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 11))
                    Text("\(currentRecipe.ingredients.count) nguyên liệu")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.surfaceSecondary)
                .clipShape(Capsule())

                if currentRecipe.totalTimeMinutes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("\(currentRecipe.totalTimeMinutes) phút")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }

            Text(currentRecipe.name)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(AppColors.textPrimary)

            Text("Công thức gốc: \(currentRecipe.servings) phần • \(Int(currentRecipe.standardServingGrams))g / phần")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var servingsScalerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Số phần ăn hiển thị:")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Điều chỉnh để xem lượng nguyên liệu & calo tương ứng")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        if displayedServings > 1 {
                            displayedServings -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(displayedServings > 1 ? AppColors.primaryGreen : AppColors.textTertiary)
                    }
                    .disabled(displayedServings <= 1)

                    Text("\(Int(displayedServings))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(minWidth: 32)

                    Button {
                        if displayedServings < 30 {
                            displayedServings += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private var macroBreakdownCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CHO \(Int(displayedServings)) KHẨU PHẦN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(scaledNutritionForDisplayed.calories))")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                        Text("kcal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Mỗi 1 phần:")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                    Text("\(Int(perServingNutrition.calories)) kcal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }

            Divider()

            HStack(spacing: 8) {
                macroItem(title: "Đạm", value: String(format: "%.1fg", scaledNutritionForDisplayed.proteinGrams), color: Color(hex: "2B6CB0"))
                macroItem(title: "Carbs", value: String(format: "%.1fg", scaledNutritionForDisplayed.carbGrams), color: Color(hex: "C05621"))
                macroItem(title: "Béo", value: String(format: "%.1fg", scaledNutritionForDisplayed.fatGrams), color: Color(hex: "C53030"))
                macroItem(title: "Xơ", value: String(format: "%.1fg", scaledNutritionForDisplayed.fiberGrams), color: Color(hex: "27AE60"))
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
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var ingredientsCard: some View {
        let ratio = displayedServings / max(Double(currentRecipe.servings), 1)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nguyên liệu (\(Int(displayedServings)) phần)")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("Tổng: \(Int(currentRecipe.standardServingGrams * displayedServings))g")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }

            VStack(spacing: 8) {
                ForEach(currentRecipe.ingredients) { ing in
                    let ingGrams = ing.grams * ratio
                    let ingCal = ing.calories * ratio

                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 6, height: 6)

                        Text(ing.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Text("\(Int(ingGrams))g")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        Text("(\(Int(ingCal)) kcal)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.vertical, 6)

                    if ing.id != currentRecipe.ingredients.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Các bước thực hiện")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            if currentRecipe.instructions.isEmpty {
                Text("Chưa có hướng dẫn cho công thức này.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textTertiary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(currentRecipe.instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(AppColors.primaryGreen)
                                .clipShape(Circle())

                            Text(step)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
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
                    Text("Chỉnh sửa công thức")
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
                    Text("Xóa công thức này")
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
                    logRecipeToDiary()
                } label: {
                    HStack {
                        if isLogging {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                            Text("Ghi \(Int(displayedServings)) phần (\(Int(scaledNutritionForDisplayed.calories)) kcal)")
                                .font(.system(size: 14, weight: .bold))
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
        var updated = currentRecipe
        updated.isFavorite.toggle()
        Task {
            do {
                try await environment.saveRecipeUseCase.execute(updated)
                self.currentRecipe = updated
            } catch {}
        }
    }

    private func deleteRecipe() {
        Task {
            do {
                try await environment.deleteRecipeUseCase.execute(id: currentRecipe.id)
                onRecipeDeleted()
                dismiss()
            } catch {}
        }
    }

    private func logRecipeToDiary() {
        isLogging = true
        let snapshot = currentRecipe.toFoodItem(servingCount: displayedServings)
        let meal = MealRecord(
            timestamp: Date(),
            mealType: selectedMealType,
            items: [snapshot],
            notes: "Ghi từ công thức: \(currentRecipe.name) (\(Int(displayedServings)) phần)"
        )
        Task {
            do {
                try await environment.logMealUseCase.execute(meal: meal)
                isLogging = false
                NotificationCenter.default.post(name: NSNotification.Name("NutriLensMealDiaryChanged"), object: nil)
                onQuickLog(currentRecipe, displayedServings)
                dismiss()
            } catch {
                isLogging = false
            }
        }
    }
}
