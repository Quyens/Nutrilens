//
//  CreateEditRecipeView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Create & Edit Recipe Screen with live nutrition aggregation.
//

import SwiftUI

public struct CreateEditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    public let existingRecipe: Recipe?
    public let onSaved: (Recipe) -> Void

    // Form State
    @State private var name: String = ""
    @State private var servings: Int = 2
    @State private var prepTimeMinutesText: String = "15"
    @State private var cookTimeMinutesText: String = "20"
    @State private var instructionsText: String = ""
    @State private var notesText: String = ""
    @State private var isFavorite: Bool = false

    // Dynamic Ingredients
    @State private var ingredients: [RecipeIngredient] = []

    // Sheets & Feedback
    @State private var isPresentingIngredientPicker: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isSaving: Bool = false

    public init(
        existingRecipe: Recipe? = nil,
        onSaved: @escaping (Recipe) -> Void = { _ in }
    ) {
        self.existingRecipe = existingRecipe
        self.onSaved = onSaved
    }

    // Live Aggregation
    private var totalCalories: Double {
        ingredients.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Double {
        let val = ingredients.reduce(0.0) { $0 + $1.proteinGrams }
        return (val * 10).rounded() / 10
    }

    private var totalCarbs: Double {
        let val = ingredients.reduce(0.0) { $0 + $1.carbGrams }
        return (val * 10).rounded() / 10
    }

    private var totalFat: Double {
        let val = ingredients.reduce(0.0) { $0 + $1.fatGrams }
        return (val * 10).rounded() / 10
    }

    private var totalGrams: Double {
        ingredients.reduce(0) { $0 + $1.grams }
    }

    private var perServingCalories: Double {
        guard servings > 0 else { return 0 }
        return (totalCalories / Double(servings)).rounded()
    }

    private var perServingProtein: Double {
        guard servings > 0 else { return 0 }
        return ((totalProtein / Double(servings)) * 10).rounded() / 10
    }

    private var perServingCarbs: Double {
        guard servings > 0 else { return 0 }
        return ((totalCarbs / Double(servings)) * 10).rounded() / 10
    }

    private var perServingFat: Double {
        guard servings > 0 else { return 0 }
        return ((totalFat / Double(servings)) * 10).rounded() / 10
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Error message
                        if let error = errorMessage {
                            errorBanner(error)
                        }

                        // Basic Information Card
                        basicInfoCard

                        // Ingredients Builder Card
                        ingredientsBuilderCard

                        // Live Nutrition Summary Card
                        if !ingredients.isEmpty {
                            liveNutritionCard
                        }

                        // Instructions Card
                        instructionsCard

                        // Notes Card
                        notesCard

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(existingRecipe == nil ? "Tạo công thức mới" : "Sửa công thức")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveRecipe()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(AppColors.primaryGreen)
                        } else {
                            Text("Lưu")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .sheet(isPresented: $isPresentingIngredientPicker) {
                IngredientPickerSheet { newIngredient in
                    self.ingredients.append(newIngredient)
                }
            }
            .onAppear {
                populateExistingData()
            }
        }
    }

    // MARK: - Subviews
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Thông tin công thức")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Tên món ăn / công thức *")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                TextField("VD: Canh Chua Cá Hồi Healthy", text: $name)
                    .textFieldStyle(BotanicalFormTextFieldStyle())
            }

            // Servings Stepper
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Số khẩu phần nấu:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    Text("Dinh dưỡng sẽ tự động chia đều cho mỗi phần")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        if servings > 1 { servings -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(servings > 1 ? AppColors.primaryGreen : AppColors.textTertiary)
                    }
                    .disabled(servings <= 1)

                    Text("\(servings)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(minWidth: 28)

                    Button {
                        if servings < 20 { servings += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }
            .padding(.top, 4)

            Divider()

            // Prep & Cook Time
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chuẩn bị (phút)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    TextField("15", text: $prepTimeMinutesText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Nấu nướng (phút)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    TextField("20", text: $cookTimeMinutesText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var ingredientsBuilderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nguyên liệu thành phần *")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(ingredients.count) nguyên liệu")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
            }

            if ingredients.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "basket.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                    Text("Chưa có nguyên liệu nào")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Thêm các nguyên liệu từ kho món Việt 35+, món riêng của bạn hoặc nhập tay.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.surfaceSecondary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ingredient.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("\(Int(ingredient.grams))g • \(Int(ingredient.calories)) kcal")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Đ:\(Int(ingredient.proteinGrams)) C:\(Int(ingredient.carbGrams)) B:\(Int(ingredient.fatGrams))")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(AppColors.textTertiary)
                            }

                            Button {
                                ingredients.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.error)
                                    .padding(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(12)
                        .background(AppColors.surfaceSecondary.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            Button {
                isPresentingIngredientPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Thêm nguyên liệu")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppColors.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var liveNutritionCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DINH DƯỠNG MỖI KHẨU PHẦN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(perServingCalories))")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                        Text("kcal / phần")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Tổng cả nồi:")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                    Text("\(Int(totalCalories)) kcal (\(Int(totalGrams))g)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }

            Divider()

            HStack(spacing: 8) {
                nutritionPill(title: "Đạm", value: "\(perServingProtein)g", color: Color(hex: "2B6CB0"))
                nutritionPill(title: "Carbs", value: "\(perServingCarbs)g", color: Color(hex: "C05621"))
                nutritionPill(title: "Béo", value: "\(perServingFat)g", color: Color(hex: "C53030"))
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private func nutritionPill(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Các bước nấu (Hướng dẫn)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            TextField("Bước 1: Sơ chế...\nBước 2: Nấu nước dùng...\nBước 3: Nêm nếm...", text: $instructionsText, axis: .vertical)
                .lineLimit(4...10)
                .textFieldStyle(BotanicalFormTextFieldStyle())
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ghi chú & Mẹo dinh dưỡng (Tùy chọn)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            TextField("Mẹo giảm calo, thay thế gia vị...", text: $notesText, axis: .vertical)
                .lineLimit(2...5)
                .textFieldStyle(BotanicalFormTextFieldStyle())
        }
        .padding(16)
        .background(formCardBackground)
    }

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.error)
            Text(msg)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.error)
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "FFF4F2"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(hex: "FAD4CF"), lineWidth: 1))
    }

    private var formCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }

    // MARK: - Populate
    private func populateExistingData() {
        guard let recipe = existingRecipe else { return }
        name = recipe.name
        servings = max(recipe.servings, 1)
        prepTimeMinutesText = recipe.prepTimeMinutes.map { "\($0)" } ?? "15"
        cookTimeMinutesText = recipe.cookingTimeMinutes.map { "\($0)" } ?? "20"
        instructionsText = recipe.instructions.joined(separator: "\n")
        notesText = recipe.notes ?? ""
        isFavorite = recipe.isFavorite
        ingredients = recipe.ingredients
    }

    // MARK: - Save
    private func saveRecipe() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Vui lòng nhập tên công thức."
            return
        }

        guard servings >= 1 else {
            errorMessage = "Số khẩu phần phải ít nhất là 1."
            return
        }

        guard !ingredients.isEmpty else {
            errorMessage = "Vui lòng thêm ít nhất 1 nguyên liệu vào công thức."
            return
        }

        let prepTime = Int(prepTimeMinutesText) ?? 0
        let cookTime = Int(cookTimeMinutesText) ?? 0

        let instructionsList = instructionsText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let recipe = Recipe(
            id: existingRecipe?.id ?? UUID(),
            name: trimmedName,
            servings: servings,
            prepTimeMinutes: prepTime,
            cookingTimeMinutes: cookTime,
            ingredients: ingredients,
            instructions: instructionsList,
            notes: notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notesText,
            isFavorite: isFavorite,
            createdAt: existingRecipe?.createdAt ?? Date(),
            updatedAt: Date()
        )

        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await environment.saveRecipeUseCase.execute(recipe)
                isSaving = false
                onSaved(recipe)
                dismiss()
            } catch {
                isSaving = false
                errorMessage = "Không thể lưu công thức: \(error.localizedDescription)"
            }
        }
    }
}
