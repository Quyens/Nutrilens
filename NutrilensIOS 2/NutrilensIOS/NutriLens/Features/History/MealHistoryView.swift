//
//  MealHistoryView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Meal Diary V2: Fresh Premium botanical theme, horizontal weekly calendar strip,
//  real-time daily aggregates, categorized meal sections, authentic thumbnails,
//  detail inspection, editing, deletion, search & filtering, and SwiftData persistence.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct MealHistoryView: View {
    @StateObject private var viewModel: MealHistoryViewModel

    public init(viewModel: MealHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Botanical wallpaper background with subtle ivory surface overlay
                botanicalBackgroundView
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 1. Top Header: Title, Month Navigation, Today Button & Search Toggle
                    topHeaderView
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, 14)
                        .padding(.bottom, AppSpacing.xs)

                    // 2. Horizontal Weekly Calendar Strip
                    weeklyCalendarStrip
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.bottom, AppSpacing.sm)

                    // 3. Search & Category Filters (Expandable)
                    searchAndFilterBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.bottom, AppSpacing.xs)

                    // 4. Main Scrollable Journal Content
                    mainContentView
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadHistory()
            }
            .refreshable {
                await viewModel.loadHistory()
            }
            // Detail Sheet
            .sheet(item: $viewModel.selectedMealForDetails) { meal in
                MealDetailView(
                    meal: meal,
                    onEdit: { mealToEdit in
                        viewModel.selectedMealForDetails = nil
                        viewModel.mealBeingEdited = mealToEdit
                    },
                    onDelete: { mealToDelete in
                        viewModel.selectedMealForDetails = nil
                        viewModel.confirmDeletion(for: mealToDelete)
                    },
                    onDismiss: {
                        viewModel.selectedMealForDetails = nil
                    }
                )
            }
            // Edit Sheet
            .sheet(item: $viewModel.mealBeingEdited) { meal in
                EditMealView(
                    meal: meal,
                    onSave: { updatedMeal in
                        Task {
                            await viewModel.updateMeal(updatedMeal)
                        }
                    },
                    onDismiss: {
                        viewModel.mealBeingEdited = nil
                    }
                )
            }
            // Quick Add Sheet
            .sheet(item: $viewModel.categoryForQuickAdd) { category in
                QuickAddMealSheet(
                    initialCategory: category,
                    onAdd: { dish, cat, grams in
                        Task {
                            await viewModel.quickAdd(dish: dish, category: cat, servingGrams: grams)
                        }
                    },
                    onDismiss: {
                        viewModel.categoryForQuickAdd = nil
                    }
                )
            }
            // Deletion Confirmation Dialog
            .confirmationDialog(
                "Xác nhận xóa bữa ăn",
                isPresented: $viewModel.showingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: viewModel.mealPendingDeletion
            ) { meal in
                Button("Xóa khỏi nhật ký", role: .destructive) {
                    Task {
                        await viewModel.executePendingDeletion()
                    }
                }
                Button("Hủy", role: .cancel) {
                    viewModel.mealPendingDeletion = nil
                }
            } message: { meal in
                Text("Bạn có chắc chắn muốn xóa '\(meal.displayTitle)' khỏi nhật ký không? Thao tác này sẽ tự động cập nhật lại tổng calo trong ngày.")
            }
        }
    }

    // MARK: - Background

    private var botanicalBackgroundView: some View {
        ZStack {
            #if canImport(UIKit)
            if let _ = UIImage(named: "botanical_wallpaper") {
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .overlay(AppColors.background.opacity(0.92))
            } else {
                AppColors.background
            }
            #else
            AppColors.background
            #endif
        }
    }

    // MARK: - Top Header

    private var topHeaderView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nhật Ký Bữa Ăn")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 8) {
                    Text(monthYearString(from: viewModel.selectedDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)

                    // Week navigators
                    HStack(spacing: 2) {
                        Button {
                            viewModel.shiftWeek(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                                .padding(4)
                        }

                        Button {
                            viewModel.shiftWeek(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                                .padding(4)
                        }
                    }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                // Today Button
                if !Calendar.current.isDateInToday(viewModel.selectedDate) {
                    Button {
                        viewModel.selectToday()
                    } label: {
                        Text("Hôm nay")
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.primaryGreen.opacity(0.12))
                            .foregroundColor(AppColors.primaryGreen)
                            .cornerRadius(12)
                    }
                }

                // Search Toggle Button
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.isSearching.toggle()
                        if !viewModel.isSearching {
                            viewModel.searchQuery = ""
                        }
                    }
                } label: {
                    Image(systemName: viewModel.isSearching ? "xmark.circle.fill" : "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(viewModel.isSearching ? AppColors.primaryGreen : AppColors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.borderSubtle, lineWidth: 1))
                }
                .accessibilityIdentifier("diary_search_toggle")
            }
        }
    }

    // MARK: - Horizontal Weekly Calendar Strip

    private var weeklyCalendarStrip: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.currentWeekDates, id: \.self) { date in
                let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let hasMeals = viewModel.hasMeals(on: date)

                Button {
                    viewModel.selectDate(date)
                } label: {
                    VStack(spacing: 5) {
                        // Weekday: T2, T3, T4, T5, T6, T7, CN
                        Text(weekdayAbbreviation(from: date))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : AppColors.textSecondary)

                        // Day number: 1..31
                        Text(dayNumberString(from: date))
                            .font(.system(size: 16, weight: isSelected ? .bold : .semibold, design: .rounded))
                            .foregroundColor(isSelected ? .white : (isToday ? AppColors.primaryGreen : AppColors.textPrimary))

                        // Meal indicator dot
                        Circle()
                            .fill(isSelected ? Color.white : (hasMeals ? AppColors.primaryGreen : Color.clear))
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        isSelected ? AppColors.primaryGreen : AppColors.cardBackground
                    )
                    .cornerRadius(AppRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(
                                isSelected ? Color.clear : (isToday ? AppColors.primaryGreen.opacity(0.4) : AppColors.borderSubtle),
                                lineWidth: isToday ? 1.5 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? AppColors.primaryGreen.opacity(0.25) : Color.black.opacity(0.02),
                        radius: isSelected ? 4 : 2,
                        x: 0,
                        y: 2
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Search & Filter Bar

    private var searchAndFilterBar: some View {
        VStack(spacing: 8) {
            // Search Input Field
            if viewModel.isSearching {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.primaryGreen)
                        .font(.system(size: 14))

                    TextField("Tìm món ăn, ghi chú theo từ khóa...", text: $viewModel.searchQuery)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier("diary_search_field")

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Category Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    categoryFilterChip(
                        title: "Tất cả",
                        icon: "square.grid.2x2",
                        isSelected: viewModel.selectedFilter == nil,
                        action: { viewModel.selectedFilter = nil }
                    )

                    ForEach(MealType.allCases) { cat in
                        categoryFilterChip(
                            title: cat.vietnameseName,
                            icon: cat.systemIcon,
                            isSelected: viewModel.selectedFilter == cat,
                            action: { viewModel.selectedFilter = cat }
                        )
                    }
                }
            }
        }
    }

    private func categoryFilterChip(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isSelected ? AppColors.primaryGreen : AppColors.cardBackground
            )
            .foregroundColor(
                isSelected ? .white : AppColors.textSecondary
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : AppColors.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Main Scrollable Journal Content

    @ViewBuilder
    private var mainContentView: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack {
                Spacer()
                ProgressView("Đang tải nhật ký...")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }

        case .failure(let error):
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                Text("Không thể tải nhật ký")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(error.localizedDescription)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Thử lại") {
                    Task { await viewModel.loadHistory() }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryGreen)
                Spacer()
            }

        case .success:
            journalScrollView
        }
    }

    private var journalScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                // 1. Daily Summary Hero Card (Calorie ring & macro bars)
                dailySummaryCard

                // 2. Search Empty State (when user searches and finds nothing)
                if !viewModel.searchQuery.isEmpty && viewModel.filteredDayMeals.isEmpty {
                    emptySearchResultsView
                } else if viewModel.allDayMeals.isEmpty {
                    // 3. Whole Day Empty State (no meals logged at all on this date)
                    emptyDayCardView
                } else {
                    // 4. Grouped Categorized Sections: Breakfast, Lunch, Dinner, Snack
                    let categoriesToShow: [MealType] = {
                        if let filter = viewModel.selectedFilter {
                            return [filter]
                        }
                        return MealType.allCases
                    }()

                    ForEach(categoriesToShow) { category in
                        mealCategorySection(category: category)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, 130) // Minimum 130pt bottom clearance for floating TabBar!
        }
    }

    // MARK: - Daily Summary Hero Card

    private var dailySummaryCard: some View {
        VStack(spacing: 12) {
            // Calorie Header Row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TỔNG NĂNG LƯỢNG NGÀY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(viewModel.totalCalories))")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("/ \(Int(viewModel.targetCalories)) kcal")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                // Remaining kcal badge
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Còn lại")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(Int(viewModel.remainingCalories)) kcal")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.remainingCalories > 0 ? AppColors.primaryGreen : .orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    (viewModel.remainingCalories > 0 ? AppColors.primaryGreen : Color.orange).opacity(0.1)
                )
                .cornerRadius(10)
            }

            // Calorie Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.borderSubtle)
                        .frame(height: 7)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryGreen, AppColors.primaryGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width * CGFloat(viewModel.calorieProgress), geo.size.width)), height: 7)
                }
            }
            .frame(height: 7)

            Divider()
                .padding(.vertical, 2)

            // Macronutrient Summary Pills (Protein, Carbs, Fat, Fiber)
            HStack(spacing: 8) {
                macroSummaryItem(
                    name: "Đạm",
                    consumed: viewModel.totalProtein,
                    target: viewModel.targetProtein,
                    color: .blue
                )

                macroSummaryItem(
                    name: "Carbs",
                    consumed: viewModel.totalCarbs,
                    target: viewModel.targetCarbs,
                    color: .orange
                )

                macroSummaryItem(
                    name: "Béo",
                    consumed: viewModel.totalFat,
                    target: viewModel.targetFat,
                    color: .purple
                )

                macroSummaryItem(
                    name: "Xơ",
                    consumed: viewModel.totalFiber,
                    target: viewModel.targetFiber,
                    color: .teal
                )
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColors.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func macroSummaryItem(name: String, consumed: Double, target: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            Text("\(Int(consumed))g")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("/\(Int(target))g")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.06))
        .cornerRadius(8)
    }

    // MARK: - Meal Category Section

    private func mealCategorySection(category: MealType) -> some View {
        let meals = viewModel.meals(for: category)
        let totalCal = viewModel.categoryCalories(for: category)

        return VStack(alignment: .leading, spacing: 8) {
            // Category Section Header
            HStack {
                HStack(spacing: 6) {
                    Text(categoryEmoji(category))
                        .font(.system(size: 16))
                    Text(category.vietnameseName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    if totalCal > 0 {
                        Text("• \(Int(totalCal)) kcal")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }

                Spacer()

                // "+ Thêm món" Button for this category
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    viewModel.categoryForQuickAdd = category
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Thêm")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppColors.primaryGreen.opacity(0.12))
                    .foregroundColor(AppColors.primaryGreen)
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("diary_add_button_\(category.rawValue)")
            }
            .padding(.top, 4)

            // Section Meal Cards
            if meals.isEmpty {
                // Subtle empty slot
                categoryEmptySlotView(category: category)
            } else {
                VStack(spacing: 8) {
                    ForEach(meals) { meal in
                        diaryMealCard(meal: meal)
                    }
                }
            }
        }
    }

    private func categoryEmptySlotView(category: MealType) -> some View {
        Button {
            viewModel.categoryForQuickAdd = category
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                Text("Chưa ghi nhận \(category.vietnameseName.lowercased()). Nhấn để thêm món...")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 12)
            .background(AppColors.cardBackground.opacity(0.6))
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.borderSubtle, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Diary Meal Card

    private func diaryMealCard(meal: MealRecord) -> some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            viewModel.selectedMealForDetails = meal
        } label: {
            HStack(spacing: 12) {
                // Authentic Food Thumbnail
                mealThumbnail(meal: meal)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                // Dish Info & Macros
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(meal.displayTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Text("\(Int(meal.totalCalories)) kcal")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                    }

                    HStack(spacing: 6) {
                        Text("\(Int(meal.totalServingGrams))g")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)

                        Text("•")
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))

                        Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Mini Macro Pills
                    HStack(spacing: 6) {
                        Text("P: \(Int(meal.totalProteinGrams))g")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)

                        Text("C: \(Int(meal.totalCarbGrams))g")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)

                        Text("F: \(Int(meal.totalFatGrams))g")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(AppSpacing.sm + 2)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColors.borderSubtle, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("diary_meal_card_\(meal.id.uuidString)")
        .contextMenu {
            Button {
                viewModel.mealBeingEdited = meal
            } label: {
                Label("Chỉnh sửa bữa ăn", systemImage: "pencil")
            }

            Button(role: .destructive) {
                viewModel.confirmDeletion(for: meal)
            } label: {
                Label("Xóa khỏi nhật ký", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.confirmDeletion(for: meal)
            } label: {
                Label("Xóa", systemImage: "trash")
            }

            Button {
                viewModel.mealBeingEdited = meal
            } label: {
                Label("Sửa", systemImage: "pencil")
            }
            .tint(AppColors.primaryGreen)
        }
    }

    @ViewBuilder
    private func mealThumbnail(meal: MealRecord) -> some View {
        #if canImport(UIKit)
        if let path = meal.imagePath, let img = UIImage(named: path) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else if let path = meal.imagePath, let fileImg = UIImage(contentsOfFile: path) {
            Image(uiImage: fileImg)
                .resizable()
                .scaledToFill()
        } else {
            // Fallback icon squircle
            ZStack {
                AppColors.primaryGreen.opacity(0.12)
                Image(systemName: meal.mealType.systemIcon)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
        #else
        ZStack {
            AppColors.primaryGreen.opacity(0.12)
            Image(systemName: meal.mealType.systemIcon)
                .font(.system(size: 22))
                .foregroundColor(AppColors.primaryGreen)
        }
        #endif
    }

    // MARK: - Empty States

    private var emptyDayCardView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 44))
                .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                .padding(.top, AppSpacing.sm)

            Text("Chưa có bữa ăn nào được ghi")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("Ghi nhận các món bạn đã thưởng thức trong ngày để theo dõi calo và dinh dưỡng chính xác.")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.md)

            Button {
                viewModel.categoryForQuickAdd = .breakfast
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Ghi bữa ăn đầu tiên")
                }
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppColors.primaryGreen)
                .foregroundColor(.white)
                .cornerRadius(AppRadius.md)
                .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 4)
            .padding(.bottom, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColors.borderSubtle, lineWidth: 1)
        )
    }

    private var emptySearchResultsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                .padding(.top, AppSpacing.md)

            Text("Không tìm thấy kết quả")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("Không có món ăn nào khớp với '\(viewModel.searchQuery)' trong ngày đã chọn.")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            Button("Xóa tìm kiếm") {
                viewModel.searchQuery = ""
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(AppColors.primaryGreen)
            .padding(.bottom, AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColors.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Date Formatting Helpers

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "LLLL, yyyy"
        return formatter.string(from: date).capitalized
    }

    private func weekdayAbbreviation(from date: Date) -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 2: return "T2"
        case 3: return "T3"
        case 4: return "T4"
        case 5: return "T5"
        case 6: return "T6"
        case 7: return "T7"
        case 1: return "CN"
        default: return ""
        }
    }

    private func dayNumberString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
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
