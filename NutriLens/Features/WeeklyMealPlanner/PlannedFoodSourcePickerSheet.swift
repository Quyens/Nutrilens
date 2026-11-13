//
//  PlannedFoodSourcePickerSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Reusable food picker from 3 sources: Vietnamese DB, Custom Foods & Recipes.
//

import SwiftUI

public struct PlannedFoodSourcePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    let onSelectFood: (PlannedFoodItem) -> Void

    @State private var selectedSource: PlannedFoodSourceType = .vietnameseDatabase
    @State private var searchQuery: String = ""

    // Loaded Data
    @State private var customFoods: [CustomFood] = []
    @State private var recipes: [Recipe] = []
    @State private var isLoadingData: Bool = false

    // Stage item before adding
    @State private var stagingItem: StagingPickerItem? = nil

    public init(onSelectFood: @escaping (PlannedFoodItem) -> Void) {
        self.onSelectFood = onSelectFood
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented Source Picker
                    sourceSegmentPicker
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.sm)

                    // Search Bar
                    searchBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.vertical, AppSpacing.sm)

                    // Content List
                    contentList
                }
            }
            .navigationTitle("Chọn món vào kế hoạch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Đóng") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
            .sheet(item: $stagingItem) { item in
                StagingPortionSheet(item: item) { plannedItem in
                    onSelectFood(plannedItem)
                    stagingItem = nil
                    dismiss()
                }
            }
            .task {
                await loadSources()
            }
        }
    }

    // MARK: - Source Segment Picker
    private var sourceSegmentPicker: some View {
        HStack(spacing: 6) {
            PickerTabButton(
                title: "Món Việt (35+)",
                icon: "fork.knife",
                isSelected: selectedSource == .vietnameseDatabase
            ) {
                selectedSource = .vietnameseDatabase
            }

            PickerTabButton(
                title: "Món của bạn",
                icon: "heart.text.square",
                isSelected: selectedSource == .customFood
            ) {
                selectedSource = .customFood
            }

            PickerTabButton(
                title: "Công thức",
                icon: "book.pages",
                isSelected: selectedSource == .recipe
            ) {
                selectedSource = .recipe
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)

            TextField("Tìm theo tên món...", text: $searchQuery)
                .font(.system(size: 14))

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
    }

    // MARK: - Content List
    @ViewBuilder
    private var contentList: some View {
        switch selectedSource {
        case .vietnameseDatabase:
            vietnameseDishList
        case .customFood:
            customFoodList
        case .recipe:
            recipeList
        case .packagedFood:
            EmptyView()
        case .manual:
            EmptyView()
        }
    }

    // MARK: - Vietnamese Dish List
    private func normalize(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }

    private var filteredVietnameseDishes: [VietnameseDishProfile] {
        let all = VietnameseNutritionDatabase.dishes
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return all
        }
        let q = normalize(searchQuery)
        return all.filter { dish in
            normalize(dish.vietnameseName).contains(q) ||
            normalize(dish.englishName).contains(q) ||
            normalize(dish.category).contains(q)
        }
    }

    private var vietnameseDishList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredVietnameseDishes.isEmpty {
                    emptySearchState
                } else {
                    ForEach(filteredVietnameseDishes) { dish in
                        FoodPickerRow(
                            title: dish.vietnameseName,
                            subtitle: dish.category,
                            servingText: "\(Int(dish.standardServingGrams))g",
                            calories: "\(Int(dish.caloriesPerServing)) kcal",
                            protein: "P: \(Int(dish.proteinPerServing))g",
                            onSelect: {
                                stagingItem = .vietnamese(dish)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    // MARK: - Custom Food List
    private var filteredCustomFoods: [CustomFood] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return customFoods
        }
        let q = normalize(searchQuery)
        return customFoods.filter { food in
            normalize(food.name).contains(q) ||
            normalize(food.category).contains(q)
        }
    }

    private var customFoodList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredCustomFoods.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                        Text(customFoods.isEmpty ? "Bạn chưa tạo món ăn cá nhân nào" : "Không tìm thấy món phù hợp")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(filteredCustomFoods) { food in
                        FoodPickerRow(
                            title: food.name,
                            subtitle: food.category,
                            servingText: "\(Int(food.servingSizeGrams))\(food.servingUnit)",
                            calories: "\(Int(food.calories)) kcal",
                            protein: "P: \(String(format: "%.1f", food.proteinGrams))g",
                            onSelect: {
                                stagingItem = .customFood(food)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    // MARK: - Recipe List
    private var filteredRecipes: [Recipe] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return recipes
        }
        let q = normalize(searchQuery)
        return recipes.filter { recipe in
            normalize(recipe.name).contains(q)
        }
    }

    private var recipeList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredRecipes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                        Text(recipes.isEmpty ? "Bạn chưa tạo công thức nào" : "Không tìm thấy công thức phù hợp")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(filteredRecipes) { recipe in
                        let snap = recipe.perServingNutrition
                        FoodPickerRow(
                            title: recipe.name,
                            subtitle: "\(recipe.servings) khẩu phần • \(recipe.totalTimeMinutes) phút",
                            servingText: "1 phần",
                            calories: "\(Int(snap.calories)) kcal",
                            protein: "P: \(String(format: "%.1f", snap.proteinGrams))g",
                            onSelect: {
                                stagingItem = .recipe(recipe)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    private var emptySearchState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(AppColors.textSecondary)
            Text("Không tìm thấy món ăn nào")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func loadSources() async {
        isLoadingData = true
        do {
            self.customFoods = try await environment.getCustomFoodsUseCase.execute()
            self.recipes = try await environment.getRecipesUseCase.execute()
            isLoadingData = false
        } catch {
            isLoadingData = false
        }
    }
}

// MARK: - Picker Subviews
private struct PickerTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.primaryGreen : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FoodPickerRow: View {
    let title: String
    let subtitle: String
    let servingText: String
    let calories: String
    let protein: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.primaryGreen)

                        Text("•")
                            .foregroundColor(AppColors.textSecondary)

                        Text(servingText)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(calories)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)

                    Text(protein)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.proteinBlue)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryGreen)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Staging Enum & Sheet
private enum StagingPickerItem: Identifiable {
    case vietnamese(VietnameseDishProfile)
    case customFood(CustomFood)
    case recipe(Recipe)

    var id: String {
        switch self {
        case .vietnamese(let dish): return "vn_\(dish.slug)"
        case .customFood(let food): return "cf_\(food.id.uuidString)"
        case .recipe(let recipe): return "rc_\(recipe.id.uuidString)"
        }
    }
}

private struct StagingPortionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: StagingPickerItem
    let onConfirm: (PlannedFoodItem) -> Void

    @State private var quantity: Double = 100

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Dish Name
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text(categoryText)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 10)

                // Quantity / Portion Stepper & Slider
                VStack(spacing: 12) {
                    Text("\(Int(quantity)) \(unit)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)

                    Slider(value: $quantity, in: range, step: step)
                        .tint(AppColors.primaryGreen)

                    HStack {
                        Text("\(Int(range.lowerBound)) \(unit)")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text("\(Int(range.upperBound)) \(unit)")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
                .background(AppColors.mintSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                // Calculated Nutrition Preview
                let snap = computedSnapshot
                HStack(spacing: 16) {
                    NutrientMiniCard(title: "Năng lượng", value: "\(Int(snap.calories)) kcal", color: AppColors.primaryGreen)
                    NutrientMiniCard(title: "Đạm", value: "\(Int(snap.proteinGrams))g", color: AppColors.proteinBlue)
                    NutrientMiniCard(title: "Carb", value: "\(Int(snap.carbGrams))g", color: AppColors.carbOrange)
                    NutrientMiniCard(title: "Béo", value: "\(Int(snap.fatGrams))g", color: AppColors.fatRed)
                }

                Spacer()

                // Add Button
                Button(action: {
                    let plannedItem = makePlannedItem()
                    onConfirm(plannedItem)
                }) {
                    Text("Thêm vào kế hoạch")
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
            }
            .padding(AppSpacing.screenHorizontal)
            .navigationTitle("Điều chỉnh khẩu phần")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onAppear {
                initQuantity()
            }
        }
        .presentationDetents([.height(380)])
    }

    private var title: String {
        switch item {
        case .vietnamese(let dish): return dish.vietnameseName
        case .customFood(let food): return food.name
        case .recipe(let recipe): return recipe.name
        }
    }

    private var categoryText: String {
        switch item {
        case .vietnamese(let dish): return "Món Việt • \(dish.category)"
        case .customFood(let food): return "Món tự tạo • \(food.category)"
        case .recipe(let recipe): return "Công thức • \(recipe.servings) phần"
        }
    }

    private var unit: String {
        switch item {
        case .vietnamese: return "g"
        case .customFood(let food): return food.servingUnit
        case .recipe: return "phần"
        }
    }

    private var range: ClosedRange<Double> {
        switch item {
        case .vietnamese: return 50...1000
        case .customFood: return 20...1000
        case .recipe: return 0.5...8.0
        }
    }

    private var step: Double {
        switch item {
        case .vietnamese, .customFood: return 10
        case .recipe: return 0.5
        }
    }

    private func initQuantity() {
        switch item {
        case .vietnamese(let dish):
            quantity = dish.standardServingGrams
        case .customFood(let food):
            quantity = food.servingSizeGrams
        case .recipe:
            quantity = 1.0
        }
    }

    private var computedSnapshot: PlannedNutritionSnapshot {
        switch item {
        case .vietnamese(let dish):
            let factor = quantity / max(dish.standardServingGrams, 1.0)
            return PlannedNutritionSnapshot(
                calories: (dish.caloriesPerServing * factor).rounded(),
                proteinGrams: ((dish.proteinPerServing * factor) * 10).rounded() / 10,
                carbGrams: ((dish.carbPerServing * factor) * 10).rounded() / 10,
                fatGrams: ((dish.fatPerServing * factor) * 10).rounded() / 10,
                fiberGrams: ((dish.fiberPerServing * factor) * 10).rounded() / 10
            )
        case .customFood(let food):
            let scaled = food.scaled(to: quantity)
            return PlannedNutritionSnapshot(
                calories: scaled.calories,
                proteinGrams: scaled.proteinGrams,
                carbGrams: scaled.carbGrams,
                fatGrams: scaled.fatGrams,
                fiberGrams: scaled.fiberGrams
            )
        case .recipe(let recipe):
            let snap = recipe.scaledNutrition(forServings: quantity)
            return PlannedNutritionSnapshot(
                calories: snap.calories,
                proteinGrams: snap.proteinGrams,
                carbGrams: snap.carbGrams,
                fatGrams: snap.fatGrams,
                fiberGrams: snap.fiberGrams
            )
        }
    }

    private func makePlannedItem() -> PlannedFoodItem {
        switch item {
        case .vietnamese(let dish):
            return PlannedFoodItem.fromVietnameseDish(dish, quantityGrams: quantity)
        case .customFood(let food):
            return PlannedFoodItem.fromCustomFood(food, quantityGrams: quantity)
        case .recipe(let recipe):
            return PlannedFoodItem.fromRecipe(recipe, servings: quantity)
        }
    }
}

private struct NutrientMiniCard: View {
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
