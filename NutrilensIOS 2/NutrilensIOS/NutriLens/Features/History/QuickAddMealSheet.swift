//
//  QuickAddMealSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presents a searchable catalog of canonical Vietnamese dishes with portion adjustment
//  for rapid addition to any meal category in Meal Diary V2.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct QuickAddMealSheet: View {
    let initialCategory: MealType
    let onAdd: (VietnameseDishProfile, MealType, Double) -> Void
    let onDismiss: () -> Void

    @State private var selectedCategory: MealType
    @State private var searchQuery: String = ""
    @State private var selectedDish: VietnameseDishProfile? = nil
    @State private var portionGrams: Double = 400
    @State private var showingFullExplorer: Bool = false

    public init(
        initialCategory: MealType,
        onAdd: @escaping (VietnameseDishProfile, MealType, Double) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialCategory = initialCategory
        self.onAdd = onAdd
        self.onDismiss = onDismiss
        _selectedCategory = State(initialValue: initialCategory)
    }

    private var filteredDishes: [VietnameseDishProfile] {
        let clean = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty {
            return VietnameseNutritionDatabase.dishes
        }
        return VietnameseNutritionDatabase.dishes.filter {
            $0.vietnameseName.lowercased().contains(clean) ||
            $0.englishName.lowercased().contains(clean) ||
            $0.category.lowercased().contains(clean) ||
            $0.keywords.contains { $0.lowercased().contains(clean) }
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category Picker Bar
                    categorySelectorBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.sm)

                    // Search Input Bar
                    searchBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.vertical, AppSpacing.sm)

                    // Dish List or Empty
                    if filteredDishes.isEmpty {
                        emptySearchResultView
                    } else {
                        dishListView
                    }

                    // Bottom Action Dock if a dish is selected
                    if let dish = selectedDish {
                        bottomPortionBar(dish: dish)
                    }
                }
            }
            .navigationTitle("Thêm món ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        onDismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingFullExplorer = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "safari")
                            Text("Khám phá")
                        }
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }
            .sheet(isPresented: $showingFullExplorer) {
                FoodExplorerView()
            }
        }
    }

    // MARK: - Subviews

    private var categorySelectorBar: some View {
        HStack(spacing: 8) {
            ForEach(MealType.allCases, id: \.self) { cat in
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    selectedCategory = cat
                } label: {
                    HStack(spacing: 4) {
                        Text(categoryEmoji(cat))
                        Text(cat.vietnameseName)
                            .font(.system(size: 12, weight: selectedCategory == cat ? .bold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
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

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            TextField("Tìm kiếm phở, cơm tấm, bún chả...", text: $searchQuery)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textPrimary)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColors.borderSubtle, lineWidth: 1)
        )
    }

    private var dishListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(filteredDishes, id: \.id) { dish in
                    dishRow(dish: dish)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, selectedDish != nil ? 140 : 30)
        }
    }

    private func dishRow(dish: VietnameseDishProfile) -> some View {
        let isSelected = selectedDish?.id == dish.id
        return Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if selectedDish?.id == dish.id {
                    selectedDish = nil
                } else {
                    selectedDish = dish
                    portionGrams = Double(dish.standardServingGrams)
                }
            }
        } label: {
            HStack(spacing: 12) {
                // Dish Thumbnail
                dishThumbnail(slug: dish.slug)
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))

                VStack(alignment: .leading, spacing: 3) {
                    Text(dish.vietnameseName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(dish.englishName)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text("\(Int(dish.standardServingGrams))g")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)

                        Text("•")
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))

                        Text("\(Int(dish.caloriesPerServing)) kcal")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.6))
            }
            .padding(AppSpacing.sm)
            .background(
                isSelected ? AppColors.primaryGreen.opacity(0.08) : AppColors.cardBackground
            )
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(isSelected ? AppColors.primaryGreen : AppColors.borderSubtle, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("quick_add_row_\(dish.slug)")
    }

    @ViewBuilder
    private func dishThumbnail(slug: String) -> some View {
        #if canImport(UIKit)
        if let uiImg = UIImage(named: slug) {
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                AppColors.primaryGreen.opacity(0.12)
                Image(systemName: "fork.knife")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
        #else
        ZStack {
            AppColors.primaryGreen.opacity(0.12)
            Image(systemName: "fork.knife")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryGreen)
        }
        #endif
    }

    private var emptySearchResultView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            Text("Không tìm thấy món")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            Text("Thử tìm với từ khóa khác như 'bún', 'cơm', 'phở'...")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
            Spacer()
        }
    }

    private func bottomPortionBar(dish: VietnameseDishProfile) -> some View {
        let ratio = portionGrams / Double(dish.standardServingGrams)
        let calcCal = Int((Double(dish.caloriesPerServing) * ratio).rounded())

        return VStack(spacing: 10) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dish.vietnameseName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Text("\(Int(portionGrams))g • \(calcCal) kcal vào \(selectedCategory.vietnameseName)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primaryGreen)
                }

                Spacer()

                // Stepper
                HStack(spacing: 8) {
                    Button {
                        if portionGrams > 50 {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            portionGrams -= 25
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryGreen)
                    }

                    Text("\(Int(portionGrams))g")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(minWidth: 48)

                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        portionGrams += 25
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }

            // Confirm Add Button
            Button {
                #if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
                onAdd(dish, selectedCategory, portionGrams)
                onDismiss()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ghi vào nhật ký")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryGreen)
                .foregroundColor(.white)
                .cornerRadius(AppRadius.md)
            }
            .accessibilityIdentifier("quick_add_confirm_button")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.md)
        .background(AppColors.cardBackground)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
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
