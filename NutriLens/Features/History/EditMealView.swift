//
//  EditMealView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Enables users to modify food name, portion weight, meal category, timestamp,
//  and fine-tune nutritional values with live recalculation and input validation.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct EditMealView: View {
    let originalMeal: MealRecord
    let onSave: (MealRecord) -> Void
    let onDismiss: () -> Void

    // Form Editable States
    @State private var foodName: String
    @State private var selectedCategory: MealType
    @State private var timestamp: Date
    @State private var portionGrams: Double
    @State private var calories: Double
    @State private var protein: Double
    @State private var carbs: Double
    @State private var fat: Double
    @State private var fiber: Double
    @State private var notes: String
    @State private var imagePath: String?

    // Autocomplete & Recalculation States
    @State private var matchedProfile: VietnameseDishProfile?
    @State private var isCustomNutrition: Bool = false
    @State private var validationError: String? = nil

    public init(
        meal: MealRecord,
        onSave: @escaping (MealRecord) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.originalMeal = meal
        self.onSave = onSave
        self.onDismiss = onDismiss

        let initialFood = meal.items.first
        let name = initialFood?.vietnameseName ?? meal.displayTitle
        _foodName = State(initialValue: name)
        _selectedCategory = State(initialValue: meal.mealType)
        _timestamp = State(initialValue: meal.timestamp)
        _portionGrams = State(initialValue: max(50, initialFood?.servingSizeGrams ?? 350))
        _calories = State(initialValue: meal.totalCalories)
        _protein = State(initialValue: meal.totalProteinGrams)
        _carbs = State(initialValue: meal.totalCarbGrams)
        _fat = State(initialValue: meal.totalFatGrams)
        _fiber = State(initialValue: meal.totalFiberGrams)
        _notes = State(initialValue: meal.notes ?? "")
        _imagePath = State(initialValue: meal.imagePath)

        // Find initial match
        let matched = VietnameseNutritionDatabase.dishes.first {
            $0.vietnameseName.lowercased() == name.lowercased() ||
            $0.slug == meal.imagePath
        }
        _matchedProfile = State(initialValue: matched)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.md) {
                        // Error Alert Banner
                        if let error = validationError {
                            validationBanner(error: error)
                        }

                        // 1. Dish Name & Autocomplete
                        dishNameSection

                        // 2. Meal Category
                        categorySection

                        // 3. Date & Time
                        dateTimeSection

                        // 4. Portion Size Stepper & Presets
                        portionSizeSection

                        // 5. Nutritional Values (Recalculated or Custom)
                        nutritionSection

                        // 6. User Notes
                        notesSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle("Chỉnh sửa bữa ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        onDismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .accessibilityIdentifier("edit_meal_cancel_button")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryGreen)
                    .accessibilityIdentifier("edit_meal_save_button")
                }
            }
        }
    }

    // MARK: - Sections

    private func validationBanner(error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.red)
            Spacer()
        }
        .padding(AppSpacing.sm)
        .background(Color.red.opacity(0.1))
        .cornerRadius(AppRadius.md)
    }

    private var dishNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TÊN MÓN ĂN")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(AppColors.primaryGreen)
                    TextField("Nhập tên món ăn...", text: $foodName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .onChange(of: foodName) { _, newName in
                            handleFoodNameChange(newName)
                        }
                }
                .padding(AppSpacing.sm)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColors.borderSubtle, lineWidth: 1)
                )

                // Autocomplete Suggestions
                let suggestions = autocompleteSuggestions
                if !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(suggestions, id: \.id) { dish in
                                Button {
                                    selectDishSuggestion(dish)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 10))
                                        Text(dish.vietnameseName)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.primaryGreen.opacity(0.1))
                                    .foregroundColor(AppColors.primaryGreen)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BỮA ĂN")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: 8) {
                ForEach(MealType.allCases, id: \.self) { cat in
                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        selectedCategory = cat
                    } label: {
                        VStack(spacing: 4) {
                            Text(categoryEmoji(cat))
                                .font(.system(size: 18))
                            Text(cat.vietnameseName)
                                .font(.system(size: 12, weight: selectedCategory == cat ? .bold : .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedCategory == cat ? AppColors.primaryGreen : AppColors.cardBackground
                        )
                        .foregroundColor(
                            selectedCategory == cat ? .white : AppColors.textPrimary
                        )
                        .cornerRadius(AppRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .stroke(selectedCategory == cat ? Color.clear : AppColors.borderSubtle, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THỜI GIAN DÙNG BỮA")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)

            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppColors.primaryGreen)
                DatePicker("", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                Spacer()
            }
            .padding(AppSpacing.sm)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.borderSubtle, lineWidth: 1)
            )
        }
    }

    private var portionSizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("KHẨU PHẦN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("\(Int(portionGrams))g")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
            }

            VStack(spacing: 12) {
                // Stepper Row
                HStack {
                    Button {
                        adjustPortion(by: -25)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(portionGrams > 50 ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.4))
                    }
                    .disabled(portionGrams <= 50)

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(Int(portionGrams))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("grams")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Button {
                        adjustPortion(by: 25)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 8)

                // Quick Presets
                HStack(spacing: 8) {
                    portionPresetChip(grams: 200, label: "Nhỏ (200g)")
                    portionPresetChip(grams: 350, label: "Vừa (350g)")
                    portionPresetChip(grams: 450, label: "Chuẩn (450g)")
                    portionPresetChip(grams: 600, label: "Lớn (600g)")
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.borderSubtle, lineWidth: 1)
            )
        }
    }

    private func portionPresetChip(grams: Double, label: String) -> some View {
        let isSelected = abs(portionGrams - grams) < 5
        return Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            portionGrams = grams
            recalculateNutritionFromProfile()
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isSelected ? AppColors.primaryGreen.opacity(0.15) : AppColors.surface)
                .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textSecondary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? AppColors.primaryGreen : Color.clear, lineWidth: 1)
                )
        }
        .accessibilityIdentifier("edit_portion_\(Int(grams))")
    }

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("GIÁ TRỊ DINH DƯỠNG")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                if matchedProfile != nil {
                    Text(isCustomNutrition ? "Đã điều chỉnh thủ công" : "Tự động tính từ NIN lab")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isCustomNutrition ? .orange : AppColors.primaryGreen)
                }
            }

            VStack(spacing: 10) {
                // Calories Row
                nutrientEditRow(
                    label: "Năng lượng",
                    unit: "kcal",
                    value: $calories,
                    step: 10,
                    color: AppColors.primaryGreen
                )

                Divider()

                // Protein Row
                nutrientEditRow(
                    label: "Chất đạm (Protein)",
                    unit: "g",
                    value: $protein,
                    step: 1,
                    color: .blue
                )

                // Carbs Row
                nutrientEditRow(
                    label: "Tinh bột (Carbs)",
                    unit: "g",
                    value: $carbs,
                    step: 2,
                    color: .orange
                )

                // Fat Row
                nutrientEditRow(
                    label: "Chất béo (Fat)",
                    unit: "g",
                    value: $fat,
                    step: 1,
                    color: .purple
                )

                // Fiber Row
                nutrientEditRow(
                    label: "Chất xơ (Fiber)",
                    unit: "g",
                    value: $fiber,
                    step: 0.5,
                    color: .teal
                )
            }
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.borderSubtle, lineWidth: 1)
            )
        }
    }

    private func nutrientEditRow(
        label: String,
        unit: String,
        value: Binding<Double>,
        step: Double,
        color: Color
    ) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            Spacer()

            HStack(spacing: 6) {
                Button {
                    if value.wrappedValue >= step {
                        value.wrappedValue -= step
                        isCustomNutrition = true
                    }
                } label: {
                    Image(systemName: "minus.square.fill")
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                }

                Text("\(String(format: value.wrappedValue.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value.wrappedValue)) \(unit)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(minWidth: 65, alignment: .trailing)

                Button {
                    value.wrappedValue += step
                    isCustomNutrition = true
                } label: {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GHI CHÚ")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)

            TextField("Ví dụ: Ăn ít nước béo, thêm giá sống...", text: $notes, axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(3...5)
                .padding(AppSpacing.sm)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColors.borderSubtle, lineWidth: 1)
                )
        }
    }

    // MARK: - Logic Helpers

    private var autocompleteSuggestions: [VietnameseDishProfile] {
        let clean = foodName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty else { return [] }
        return VietnameseNutritionDatabase.dishes.filter {
            $0.vietnameseName.lowercased().contains(clean) ||
            $0.keywords.contains { $0.lowercased().contains(clean) }
        }.prefix(4).map { $0 }
    }

    private func handleFoodNameChange(_ newName: String) {
        validationError = nil
        let matched = VietnameseNutritionDatabase.dishes.first {
            $0.vietnameseName.lowercased() == newName.lowercased()
        }
        if let matched = matched {
            self.matchedProfile = matched
            self.imagePath = matched.slug
            if !isCustomNutrition {
                recalculateNutritionFromProfile()
            }
        }
    }

    private func selectDishSuggestion(_ dish: VietnameseDishProfile) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.foodName = dish.vietnameseName
        self.matchedProfile = dish
        self.imagePath = dish.slug
        self.isCustomNutrition = false
        recalculateNutritionFromProfile()
    }

    private func adjustPortion(by delta: Double) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        portionGrams = max(50, portionGrams + delta)
        recalculateNutritionFromProfile()
    }

    private func recalculateNutritionFromProfile() {
        guard let profile = matchedProfile, !isCustomNutrition else { return }
        let ratio = portionGrams / Double(profile.standardServingGrams)
        calories = (Double(profile.caloriesPerServing) * ratio).rounded()
        protein = (profile.proteinPerServing * ratio * 10).rounded() / 10
        carbs = (profile.carbPerServing * ratio * 10).rounded() / 10
        fat = (profile.fatPerServing * ratio * 10).rounded() / 10
        fiber = (profile.fiberPerServing * ratio * 10).rounded() / 10
    }

    private func saveChanges() {
        let cleanName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            validationError = "Vui lòng nhập tên món ăn."
            return
        }
        guard portionGrams > 0 else {
            validationError = "Khẩu phần phải lớn hơn 0g."
            return
        }
        guard calories >= 0 else {
            validationError = "Lượng calo không hợp lệ."
            return
        }

        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif

        let updatedItem = FoodItem(
            name: matchedProfile?.englishName ?? cleanName,
            vietnameseName: cleanName,
            confidence: 1.0,
            servingSizeGrams: portionGrams,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat,
            fiberGrams: fiber
        )

        let updatedRecord = MealRecord(
            id: originalMeal.id,
            timestamp: timestamp,
            mealType: selectedCategory,
            items: [updatedItem],
            notes: notes.isEmpty ? nil : notes,
            imagePath: imagePath ?? originalMeal.imagePath
        )

        onSave(updatedRecord)
        onDismiss()
    }

    private func categoryEmoji(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "☕️"
        }
    }
}
