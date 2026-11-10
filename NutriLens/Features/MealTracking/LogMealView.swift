//
//  LogMealView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 02 Advanced Multi-Item Meal Logging View styled in Fresh Premium Botanical identity.
//  Supports multiple dishes per meal, Vietnamese nutrition database live search, portion adjustments,
//  custom food entries, and complete SwiftData persistence.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct LogMealView: View {
    @StateObject private var viewModel: LogMealViewModel
    private let onCancel: () -> Void

    @State private var selectedDishForPortion: VietnameseDishProfile? = nil
    @State private var pendingPortionGrams: Double = 400

    public init(
        viewModel: LogMealViewModel,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Global Botanical Wallpaper Background
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // MARK: - 1. Custom Top Bar (Safe below Dynamic Island)
                topFloatingBar
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 52)
                    .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - 2. Meal Type & Time Card
                        mealMetadataCard

                        // MARK: - 3. Staged Items Tray (Giỏ món ăn trong bữa)
                        stagedItemsTrayCard

                        // MARK: - 4. Live Nutrition Aggregate Card (if items staged)
                        if !viewModel.stagedItems.isEmpty {
                            liveNutritionalAggregateCard
                        }

                        // MARK: - 5. Search & Add Vietnamese Dishes
                        foodCatalogSearchSection

                        // MARK: - 6. Meal Notes
                        notesCard

                        // MARK: - 7. Error Message Banner
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.error)
                                Text(error)
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.error)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(hex: "FFF4F2"))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(hex: "FAD4CF"), lineWidth: 1))
                        }

                        // Bottom padding so content is not blocked by save button
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }

            // MARK: - Bottom Save Bar
            VStack {
                Spacer()
                bottomSaveFloatingBar
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(item: $selectedDishForPortion) { dish in
            PortionSelectionSheet(
                dish: dish,
                initialGrams: dish.standardServingGrams,
                unitFormatting: viewModel.unitFormattingService,
                haptics: viewModel.hapticFeedbackService,
                onAdd: { grams in
                    viewModel.addDishFromDatabase(dish, grams: grams)
                    selectedDishForPortion = nil
                },
                onCancel: {
                    selectedDishForPortion = nil
                }
            )
        }
        .sheet(isPresented: $viewModel.isPresentingCustomItemSheet) {
            CustomFoodEntrySheet(
                viewModel: viewModel
            )
        }
    }

    // MARK: - Subviews

    private var topFloatingBar: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)

                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ghi nhận bữa ăn")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Thêm nhiều món • Tính calo tự động")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Button(action: onCancel) {
                Text("Hủy")
                    .font(AppTypography.bodyBold)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
            }
        }
    }

    // MARK: - Metadata Card (Type & Date)
    private var mealMetadataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Loại bữa ăn & Thời gian")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            // Meal Type Pills (2x2 Grid for spacious, unclipped Vietnamese labels)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(MealType.allCases, id: \.self) { type in
                    Button {
                        viewModel.hapticFeedbackService.selection()
                        viewModel.selectedMealType = type
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.systemIcon)
                                .font(.system(size: 13, weight: .semibold))
                            Text(type.vietnameseName)
                                .font(.system(size: 13, weight: viewModel.selectedMealType == type ? .bold : .medium))
                        }
                        .foregroundColor(viewModel.selectedMealType == type ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            viewModel.selectedMealType == type
                            ? AnyView(AppColors.primaryGreen)
                            : AnyView(AppColors.surfaceSecondary.opacity(0.8))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Divider()

            // Date & Time Picker
            HStack {
                Label("Thời gian ghi nhận", systemImage: "calendar.badge.clock")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .tint(AppColors.primary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Staged Items Tray Card
    private var stagedItemsTrayCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Text("Món ăn trong bữa")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(viewModel.stagedItems.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(Capsule())
                }

                Spacer()

                Button {
                    viewModel.isPresentingCustomItemSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Tạo món riêng")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                }
            }

            if viewModel.stagedItems.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.primary.opacity(0.6))
                    Text("Bữa ăn chưa có món nào")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Tìm và chọn các món ăn từ danh mục bên dưới để thêm vào bữa ăn này.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.surfaceSecondary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.stagedItems) { item in
                        StagedItemRow(
                            item: item,
                            unitFormatting: viewModel.unitFormattingService,
                            onUpdatePortion: { newGrams in
                                viewModel.updateItemPortion(id: item.id, newGrams: newGrams)
                            },
                            onDelete: {
                                viewModel.removeItem(id: item.id)
                            }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Live Nutrition Aggregate Card
    private var liveNutritionalAggregateCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TỔNG NĂNG LƯỢNG BỮA ĂN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(viewModel.totalCalories))")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                        Text("kcal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Text("Tổng: \(viewModel.unitFormattingService.formatWeight(grams: viewModel.totalGrams))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
            }

            Divider()

            // 4 Macro Badges
            HStack(spacing: 8) {
                MacroPill(title: "Đạm", value: "\(viewModel.totalProtein)g", color: Color(hex: "4A90E2"))
                MacroPill(title: "Carbs", value: "\(viewModel.totalCarbs)g", color: Color(hex: "F5A623"))
                MacroPill(title: "Béo", value: "\(viewModel.totalFat)g", color: Color(hex: "E97970"))
                MacroPill(title: "Xơ", value: "\(viewModel.totalFiber)g", color: Color(hex: "27AE60"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Food Catalog Search Section
    private var foodCatalogSearchSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Kho 35+ món ăn Việt Nam")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(viewModel.filteredCatalogDishes.count) món")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.primary)

                TextField("Tìm món (VD: Phở bò, Cơm tấm, Bún chả...)", text: $viewModel.searchQuery)
                    .font(.system(size: 14))

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(12)
            .background(AppColors.surfaceSecondary.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Category Filter Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableCategories, id: \.self) { cat in
                        Button {
                            viewModel.hapticFeedbackService.selection()
                            viewModel.selectedCategoryFilter = cat
                        } label: {
                            Text(cat)
                                .font(.system(size: 12, weight: viewModel.selectedCategoryFilter == cat ? .bold : .medium))
                                .foregroundColor(viewModel.selectedCategoryFilter == cat ? .white : AppColors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedCategoryFilter == cat
                                    ? AnyView(AppColors.primaryGreen)
                                    : AnyView(Color.white)
                                )
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 2)
            }

            // Dish Items List
            VStack(spacing: 10) {
                ForEach(viewModel.filteredCatalogDishes.prefix(12)) { dish in
                    CatalogDishRow(
                        dish: dish,
                        unitFormatting: viewModel.unitFormattingService,
                        onSelect: {
                            selectedDishForPortion = dish
                        }
                    )
                }

                if viewModel.filteredCatalogDishes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Không tìm thấy món ăn phù hợp")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        Button {
                            viewModel.customName = viewModel.searchQuery
                            viewModel.isPresentingCustomItemSheet = true
                        } label: {
                            Text("Tạo món \"\(viewModel.searchQuery)\" tùy chỉnh ngay")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Ghi chú bữa ăn (Tùy chọn)", systemImage: "note.text")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textPrimary)

            TextField("Ví dụ: Ăn nhẹ trước khi tập, ít đường, không cay...", text: $viewModel.mealNotes)
                .font(.system(size: 13))
                .padding(12)
                .background(AppColors.surfaceSecondary.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Bottom Floating Save Bar
    private var bottomSaveFloatingBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(viewModel.stagedItems.count) món ăn")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(Int(viewModel.totalCalories)) kcal")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                }

                Spacer()

                Button {
                    viewModel.saveMeal()
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Lưu bữa ăn")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        viewModel.canSave
                        ? AnyView(AppColors.primaryGreen)
                        : AnyView(Color.gray.opacity(0.4))
                    )
                    .clipShape(Capsule())
                    .shadow(color: AppColors.primaryGreen.opacity(viewModel.canSave ? 0.3 : 0), radius: 8, y: 3)
                }
                .accessibilityIdentifier("manual_log_save_button")
                .disabled(!viewModel.canSave)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
    }
}

// MARK: - Staged Item Row
private struct StagedItemRow: View {
    let item: StagedMealItem
    let unitFormatting: UnitFormattingServiceProtocol
    let onUpdatePortion: (Double) -> Void
    let onDelete: () -> Void

    @State private var localGrams: Double

    init(
        item: StagedMealItem,
        unitFormatting: UnitFormattingServiceProtocol,
        onUpdatePortion: @escaping (Double) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self.unitFormatting = unitFormatting
        self.onUpdatePortion = onUpdatePortion
        self.onDelete = onDelete
        _localGrams = State(initialValue: item.portionGrams)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.vietnameseName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        if item.isCustom {
                            Text("Tùy chỉnh")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "F5A623"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "FFF8EC"))
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(Int(item.calories)) kcal • \(unitFormatting.formatWeight(grams: item.portionGrams))")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "E97970").opacity(0.8))
                }
            }

            // Portion Adjuster Slider
            HStack(spacing: 12) {
                Text("Khẩu phần:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                Slider(value: $localGrams, in: 50...1000, step: 25) { editing in
                    if !editing {
                        onUpdatePortion(localGrams)
                    }
                }
                .tint(AppColors.primary)

                Text(unitFormatting.formatWeight(grams: localGrams))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(width: 55, alignment: .trailing)
            }

            // Macro details
            HStack(spacing: 8) {
                Text("Đạm: \(item.proteinGrams, specifier: "%.1f")g")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "4A90E2"))
                Text("•")
                    .foregroundColor(AppColors.textTertiary)
                Text("Carb: \(item.carbGrams, specifier: "%.1f")g")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "F5A623"))
                Text("•")
                    .foregroundColor(AppColors.textTertiary)
                Text("Béo: \(item.fatGrams, specifier: "%.1f")g")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "E97970"))
                Spacer()
            }
        }
        .padding(12)
        .background(AppColors.surfaceSecondary.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Catalog Dish Row
private struct CatalogDishRow: View {
    let dish: VietnameseDishProfile
    let unitFormatting: UnitFormattingServiceProtocol
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(dish.vietnameseName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(dish.category) • \(Int(dish.caloriesPerServing)) kcal / \(unitFormatting.formatWeight(grams: dish.standardServingGrams))")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Button(action: onSelect) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Thêm")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.surfaceSecondary)
                .clipShape(Capsule())
            }
            .accessibilityIdentifier("catalog_dish_add_\(dish.slug)")
        }
        .padding(.vertical, 6)
        Divider()
    }
}

// MARK: - Macro Pill
private struct MacroPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Portion Selection Sheet
private struct PortionSelectionSheet: View {
    let dish: VietnameseDishProfile
    let initialGrams: Double
    let unitFormatting: UnitFormattingServiceProtocol
    let haptics: HapticFeedbackServiceProtocol
    let onAdd: (Double) -> Void
    let onCancel: () -> Void

    @State private var selectedGrams: Double

    init(
        dish: VietnameseDishProfile,
        initialGrams: Double,
        unitFormatting: UnitFormattingServiceProtocol,
        haptics: HapticFeedbackServiceProtocol,
        onAdd: @escaping (Double) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.dish = dish
        self.initialGrams = initialGrams
        self.unitFormatting = unitFormatting
        self.haptics = haptics
        self.onAdd = onAdd
        self.onCancel = onCancel
        _selectedGrams = State(initialValue: initialGrams)
    }

    private var scaledCalories: Double {
        let ratio = selectedGrams / max(dish.standardServingGrams, 1)
        return (dish.caloriesPerServing * ratio).rounded()
    }

    private var scaledProtein: Double {
        let ratio = selectedGrams / max(dish.standardServingGrams, 1)
        return ((dish.proteinPerServing * ratio) * 10).rounded() / 10
    }

    private var scaledCarbs: Double {
        let ratio = selectedGrams / max(dish.standardServingGrams, 1)
        return ((dish.carbPerServing * ratio) * 10).rounded() / 10
    }

    private var scaledFat: Double {
        let ratio = selectedGrams / max(dish.standardServingGrams, 1)
        return ((dish.fatPerServing * ratio) * 10).rounded() / 10
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Dish Header
                VStack(spacing: 4) {
                    Text(dish.vietnameseName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(dish.category)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 16)

                // Big Calories Display
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(scaledCalories))")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                    Text("kcal")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                }

                // Macro Row
                HStack(spacing: 12) {
                    MacroPill(title: "Đạm", value: "\(scaledProtein)g", color: Color(hex: "4A90E2"))
                    MacroPill(title: "Carbs", value: "\(scaledCarbs)g", color: Color(hex: "F5A623"))
                    MacroPill(title: "Béo", value: "\(scaledFat)g", color: Color(hex: "E97970"))
                }
                .padding(.horizontal, 24)

                // Presets
                HStack(spacing: 8) {
                    PresetButton(title: "Nhỏ (75%)", factor: 0.75, standard: dish.standardServingGrams, current: selectedGrams) {
                        selectedGrams = (dish.standardServingGrams * 0.75).rounded()
                        haptics.selection()
                    }
                    PresetButton(title: "Vừa (100%)", factor: 1.0, standard: dish.standardServingGrams, current: selectedGrams) {
                        selectedGrams = dish.standardServingGrams
                        haptics.selection()
                    }
                    PresetButton(title: "Lớn (125%)", factor: 1.25, standard: dish.standardServingGrams, current: selectedGrams) {
                        selectedGrams = (dish.standardServingGrams * 1.25).rounded()
                        haptics.selection()
                    }
                }
                .padding(.horizontal, 24)

                // Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Khẩu phần tùy chỉnh:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(unitFormatting.formatWeight(grams: selectedGrams))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                    }

                    Slider(value: $selectedGrams, in: 50...1000, step: 25)
                        .tint(AppColors.primary)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Add CTA Button
                Button {
                    onAdd(selectedGrams)
                } label: {
                    Text("Thêm vào bữa ăn (\(Int(scaledCalories)) kcal)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primaryGreen)
                        .clipShape(Capsule())
                }
                .accessibilityIdentifier("portion_confirm_add_button")
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationTitle("Chọn khẩu phần")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy", action: onCancel)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preset Button
private struct PresetButton: View {
    let title: String
    let factor: Double
    let standard: Double
    let current: Double
    let action: () -> Void

    private var isSelected: Bool {
        abs(current - (standard * factor).rounded()) < 5
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected
                    ? AnyView(AppColors.primaryGreen)
                    : AnyView(AppColors.surfaceSecondary)
                )
                .clipShape(Capsule())
        }
    }
}

// MARK: - Custom Food Entry Sheet
private struct CustomFoodEntrySheet: View {
    @ObservedObject var viewModel: LogMealViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin món ăn") {
                    TextField("Tên món ăn (VD: Canh rau dền)", text: $viewModel.customName)
                    HStack {
                        Text("Khẩu phần")
                        Spacer()
                        TextField("200", text: $viewModel.customPortionGramsText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text(viewModel.unitFormattingService.weightUnitLabel())
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Section("Dinh dưỡng ước tính") {
                    HStack {
                        Text("Năng lượng")
                        Spacer()
                        TextField("0", text: $viewModel.customCaloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Chất đạm (Protein)")
                        Spacer()
                        TextField("0", text: $viewModel.customProteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Tinh bột (Carbs)")
                        Spacer()
                        TextField("0", text: $viewModel.customCarbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Chất béo (Fat)")
                        Spacer()
                        TextField("0", text: $viewModel.customFatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Chất xơ (Fiber)")
                        Spacer()
                        TextField("0", text: $viewModel.customFiberText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Tạo món tùy chỉnh")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Thêm vào bữa") {
                        viewModel.addCustomItem()
                    }
                    .disabled(viewModel.customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
