//
//  IngredientPickerSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Ingredient Picker Sheet for Recipe Builder.
//  Allows selecting from Vietnamese Nutrition Database, User Custom Foods, or Manual Input.
//

import SwiftUI

public enum IngredientSourceTab: String, CaseIterable, Identifiable {
    case vietnamese = "Món Việt"
    case customFoods = "Món của bạn"
    case manual = "Nhập tay"

    public var id: String { rawValue }
}

public struct IngredientPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    public let onAddIngredient: (RecipeIngredient) -> Void

    @State private var selectedTab: IngredientSourceTab = .vietnamese
    @State private var searchQuery: String = ""

    // Vietnamese DB Selection
    @State private var selectedVnDish: VietnameseDishProfile? = nil
    @State private var vnGrams: Double = 100

    // Custom Foods Selection
    @State private var customFoods: [CustomFood] = []
    @State private var selectedCustomFood: CustomFood? = nil
    @State private var customFoodGrams: Double = 100

    // Manual Input
    @State private var manualName: String = ""
    @State private var manualGramsText: String = "100"
    @State private var manualCaloriesText: String = "120"
    @State private var manualProteinText: String = "5"
    @State private var manualCarbsText: String = "15"
    @State private var manualFatText: String = "2"
    @State private var manualFiberText: String = "1"
    @State private var manualErrorMessage: String? = nil

    public init(onAddIngredient: @escaping (RecipeIngredient) -> Void) {
        self.onAddIngredient = onAddIngredient
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented Tabs
                    Picker("Nguồn nguyên liệu", selection: $selectedTab) {
                        ForEach(IngredientSourceTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // Content based on tab
                    switch selectedTab {
                    case .vietnamese:
                        vietnameseDatabaseView
                    case .customFoods:
                        customFoodsView
                    case .manual:
                        manualInputView
                    }
                }
            }
            .navigationTitle("Thêm nguyên liệu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
            .onAppear {
                loadCustomFoods()
            }
        }
    }

    // MARK: - 1. Vietnamese Database Tab
    private var filteredVnDishes: [VietnameseDishProfile] {
        let clean = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        if clean.isEmpty {
            return VietnameseNutritionDatabase.dishes
        }

        return VietnameseNutritionDatabase.dishes.filter { dish in
            let vn = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let en = dish.englishName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let cat = dish.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return vn.contains(clean) || en.contains(clean) || cat.contains(clean)
        }
    }

    private var vietnameseDatabaseView: some View {
        VStack(spacing: 12) {
            // Search field
            searchBar(placeholder: "Tìm trong kho 35+ món Việt...")

            if let selected = selectedVnDish {
                // Quantity Configurator
                vnQuantityConfigurator(selected)
            } else {
                // List of dishes
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredVnDishes) { dish in
                            Button {
                                selectedVnDish = dish
                                vnGrams = dish.standardServingGrams
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(dish.vietnameseName)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("\(dish.category) • \(Int(dish.caloriesPerServing)) kcal / \(Int(dish.standardServingGrams))g")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.primaryGreen)
                                }
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func vnQuantityConfigurator(_ dish: VietnameseDishProfile) -> some View {
        let ratio = vnGrams / max(dish.standardServingGrams, 1)
        let cal = (dish.caloriesPerServing * ratio).rounded()
        let pro = ((dish.proteinPerServing * ratio) * 10).rounded() / 10
        let carb = ((dish.carbPerServing * ratio) * 10).rounded() / 10
        let fat = ((dish.fatPerServing * ratio) * 10).rounded() / 10

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(dish.vietnameseName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button("Đổi món") {
                        selectedVnDish = nil
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                }
                Text("Chuẩn: \(Int(dish.caloriesPerServing)) kcal cho \(Int(dish.standardServingGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(14)
            .background(AppColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Grams Stepper & Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Số lượng gram cần dùng:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text("\(Int(vnGrams)) g")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                }

                Slider(value: $vnGrams, in: 10...800, step: 5)
                    .tint(AppColors.primaryGreen)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Live Nutrients
            HStack(spacing: 12) {
                nutrientMini(title: "Calo", value: "\(Int(cal))", color: AppColors.primaryGreen)
                nutrientMini(title: "Đạm", value: "\(pro)g", color: Color(hex: "2B6CB0"))
                nutrientMini(title: "Carbs", value: "\(carb)g", color: Color(hex: "C05621"))
                nutrientMini(title: "Béo", value: "\(fat)g", color: Color(hex: "C53030"))
            }

            Spacer()

            Button {
                let ingredient = RecipeIngredient.fromVietnameseDish(dish, grams: vnGrams)
                onAddIngredient(ingredient)
                dismiss()
            } label: {
                Text("Thêm vào công thức")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - 2. Custom Foods Tab
    private var filteredCustomFoods: [CustomFood] {
        let clean = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        if clean.isEmpty {
            return customFoods
        }

        return customFoods.filter { food in
            let name = food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let brand = (food.brand ?? "").folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return name.contains(clean) || brand.contains(clean)
        }
    }

    private var customFoodsView: some View {
        VStack(spacing: 12) {
            searchBar(placeholder: "Tìm trong món ăn riêng của bạn...")

            if let selected = selectedCustomFood {
                customFoodQuantityConfigurator(selected)
            } else {
                if customFoods.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.textTertiary)
                        Text("Bạn chưa có món ăn riêng nào")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        Text("Hãy tạo món ăn riêng trước hoặc dùng tính năng nhập tay bên cạnh.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredCustomFoods) { food in
                                Button {
                                    selectedCustomFood = food
                                    customFoodGrams = food.servingGrams
                                } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(food.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(AppColors.textPrimary)
                                            Text("\(food.category) • \(Int(food.caloriesPerServing)) kcal / \(Int(food.servingGrams))g")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppColors.primaryGreen)
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }

    private func customFoodQuantityConfigurator(_ food: CustomFood) -> some View {
        let scaled = food.scaled(to: customFoodGrams)

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(food.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button("Đổi món") {
                        selectedCustomFood = nil
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                }
                Text("Khẩu phần gốc: \(Int(food.caloriesPerServing)) kcal cho \(Int(food.servingGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(14)
            .background(AppColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Số lượng gram cần dùng:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text("\(Int(customFoodGrams)) g")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                }

                Slider(value: $customFoodGrams, in: 10...800, step: 5)
                    .tint(AppColors.primaryGreen)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 12) {
                nutrientMini(title: "Calo", value: "\(Int(scaled.caloriesPerServing))", color: AppColors.primaryGreen)
                nutrientMini(title: "Đạm", value: String(format: "%.1fg", scaled.proteinGrams), color: Color(hex: "2B6CB0"))
                nutrientMini(title: "Carbs", value: String(format: "%.1fg", scaled.carbGrams), color: Color(hex: "C05621"))
                nutrientMini(title: "Béo", value: String(format: "%.1fg", scaled.fatGrams), color: Color(hex: "C53030"))
            }

            Spacer()

            Button {
                let ingredient = RecipeIngredient.fromCustomFood(food, grams: customFoodGrams)
                onAddIngredient(ingredient)
                dismiss()
            } label: {
                Text("Thêm vào công thức")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - 3. Manual Input Tab
    private var manualInputView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let error = manualErrorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.error)
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.error)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: "FFF4F2"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tên nguyên liệu *")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        TextField("VD: Thịt ba chỉ lát mỏng, Rau mùi...", text: $manualName)
                            .textFieldStyle(BotanicalFormTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Trọng lượng sử dụng (gram) *")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        TextField("100", text: $manualGramsText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(BotanicalFormTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Năng lượng tương ứng (kcal) *")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        TextField("100", text: $manualCaloriesText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(BotanicalFormTextFieldStyle())
                    }

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Đạm (g)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "2B6CB0"))
                            TextField("0", text: $manualProteinText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(BotanicalFormTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Carbs (g)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "C05621"))
                            TextField("0", text: $manualCarbsText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(BotanicalFormTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Béo (g)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "C53030"))
                            TextField("0", text: $manualFatText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(BotanicalFormTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Xơ (g)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "27AE60"))
                            TextField("0", text: $manualFiberText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(BotanicalFormTextFieldStyle())
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                Button {
                    addManualIngredient()
                } label: {
                    Text("Thêm nguyên liệu này")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Helper Views & Functions
    private func searchBar(placeholder: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.primaryGreen)
            TextField(placeholder, text: $searchQuery)
                .font(.system(size: 14))
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func nutrientMini(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func loadCustomFoods() {
        Task {
            do {
                self.customFoods = try await environment.getCustomFoodsUseCase.execute()
            } catch {}
        }
    }

    private func addManualIngredient() {
        let trimmedName = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            manualErrorMessage = "Vui lòng nhập tên nguyên liệu."
            return
        }

        let grams = Double(manualGramsText.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard grams > 0 else {
            manualErrorMessage = "Trọng lượng phải lớn hơn 0g."
            return
        }

        let cal = Double(manualCaloriesText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let pro = Double(manualProteinText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let carb = Double(manualCarbsText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fat = Double(manualFatText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fiber = Double(manualFiberText.replacingOccurrences(of: ",", with: ".")) ?? 0

        let ingredient = RecipeIngredient(
            name: trimmedName,
            sourceType: .manual,
            sourceReferenceId: nil,
            amountGrams: grams,
            servingUnit: "g",
            calories: cal,
            proteinGrams: pro,
            carbGrams: carb,
            fatGrams: fat,
            fiberGrams: fiber,
            notes: nil
        )

        onAddIngredient(ingredient)
        dismiss()
    }
}
