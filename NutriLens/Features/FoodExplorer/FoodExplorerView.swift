//
//  FoodExplorerView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Food Database & Explorer V1 Discovery Interface.
//

import SwiftUI

public struct FoodExplorerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: FoodExplorerViewModel

    public init(viewModel: FoodExplorerViewModel? = nil) {
        // Will initialize via state object or injected
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            // Placeholder, real init in onAppear if needed
            _viewModel = StateObject(wrappedValue: FoodExplorerViewModel(favoritesRepository: FoodFavoritesRepository()))
        }
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Fresh Premium Botanical Background
            AppColors.canvasBackground
                .ignoresSafeArea()

            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Dynamic Island Safe Top Floating Bar
                topFloatingBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Title header
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Kho tàng ẩm thực Việt")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))

                            Text("35+ món ăn truyền thống chuẩn hóa calo & dinh dưỡng")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.35, green: 0.48, blue: 0.40))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2)
                        .padding(.top, 4)

                        // Search Bar
                        searchSection

                        // Category Filter Pills
                        categoryFilterSection

                        // Favorites active banner
                        if viewModel.onlyFavorites {
                            favoritesActiveBanner
                        }

                        // Featured carousel (only when not searching and not filtering to favorites)
                        if viewModel.searchQuery.isEmpty && !viewModel.onlyFavorites && viewModel.selectedCategory == .all {
                            featuredSection

                            if !viewModel.recentlyViewedDishes.isEmpty {
                                recentlyViewedSection
                            }
                        }

                        // Food Catalog Grid
                        catalogSection
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
        }
        .fullScreenCover(item: $viewModel.selectedDishForDetail) { dish in
            FoodDetailView(dish: dish, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadData()
            if ProcessInfo.processInfo.arguments.contains("-startFoodDetail") {
                if let firstDish = viewModel.filteredDishes.first {
                    viewModel.openDishDetail(dish: firstDish)
                }
            }
        }
    }

    // MARK: - Dynamic Island Safe Top Bar
    private var topFloatingBar: some View {
        HStack {
            // Back Button Pill
            Button(action: {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("Quay lại")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.95))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                .overlay(
                    Capsule().stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                )
            }

            Spacer()

            // Centered Title Badge
            HStack(spacing: 6) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                Text("Khám phá món ăn")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))
            }

            Spacer()

            // Favorites filter shortcut button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.onlyFavorites.toggle()
                }
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            }) {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.onlyFavorites ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(viewModel.onlyFavorites ? Color(hex: "E97970") : AppColors.textSecondary)

                    if viewModel.favoritesCount > 0 {
                        Text("\(viewModel.favoritesCount)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.onlyFavorites ? Color(hex: "E97970") : AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(viewModel.onlyFavorites ? Color(hex: "FDE8E7") : Color.white.opacity(0.95))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                .overlay(
                    Capsule().stroke(viewModel.onlyFavorites ? Color(hex: "E97970").opacity(0.5) : Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
                )
            }
            .accessibilityLabel("Lọc món yêu thích")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 54) // Dynamic Island safe
        .padding(.bottom, 10)
    }

    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primaryGreen)

            TextField("Tìm kiếm theo tên, từ khóa hoặc mã...", text: $viewModel.searchQuery)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .autocorrectionDisabled()

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textTertiary)
                }
                .accessibilityLabel("Xóa tìm kiếm")
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Category Filters
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(FoodExplorerCategory.allCases) { category in
                    let isSelected = viewModel.selectedCategory == category
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedCategory = category
                        }
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))

                            Text(category.title)
                                .font(AppTypography.subheadlineBold)
                        }
                        .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? AppColors.primaryGreen : Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.03), radius: 4, x: 0, y: 2)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? AppColors.primaryGreen : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Favorites Active Banner
    private var favoritesActiveBanner: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundColor(Color(hex: "E97970"))
            Text("Đang hiển thị danh sách món ăn yêu thích")
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button("Xem tất cả") {
                withAnimation {
                    viewModel.onlyFavorites = false
                }
            }
            .font(AppTypography.captionBold)
            .foregroundColor(AppColors.primaryGreen)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 8)
        .background(AppColors.mintSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }

    // MARK: - Featured Carousel
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.primaryGreen)
                    .font(.system(size: 15))

                Text("Món ăn tiêu biểu")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.featuredDishes) { dish in
                        FeaturedFoodCard(dish: dish) {
                            viewModel.openDishDetail(dish: dish)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Recently Viewed Section
    private var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(AppColors.primaryGreen)
                    .font(.system(size: 14))

                Text("Đã xem gần đây")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button("Xóa") {
                    withAnimation {
                        viewModel.clearRecentlyViewed()
                    }
                }
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.recentlyViewedDishes) { dish in
                        Button(action: {
                            viewModel.openDishDetail(dish: dish)
                        }) {
                            HStack(spacing: 8) {
                                Image(dish.assetImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dish.vietnameseName)
                                        .font(AppTypography.captionBold)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(1)

                                    Text("\(Int(dish.caloriesPerServing)) kcal")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(AppColors.primaryGreen)
                                }
                                .frame(maxWidth: 110, alignment: .leading)
                            }
                            .padding(6)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                            .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Food Catalog Grid
    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(viewModel.onlyFavorites ? "Món yêu thích" : "Danh mục thực phẩm")
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(viewModel.filteredDishes.count) món")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
            }

            if viewModel.filteredDishes.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ],
                    spacing: 14
                ) {
                    ForEach(viewModel.filteredDishes) { dish in
                        FoodCatalogCard(
                            dish: dish,
                            isFavorite: viewModel.isFavorite(dishId: dish.id),
                            onToggleFavorite: {
                                viewModel.toggleFavorite(dishId: dish.id)
                            },
                            onSelect: {
                                viewModel.openDishDetail(dish: dish)
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: viewModel.onlyFavorites ? "heart.slash" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(AppColors.sageGreen)
                .padding(.top, AppSpacing.lg)

            Text(viewModel.onlyFavorites ? "Chưa có món yêu thích" : "Không tìm thấy món ăn phù hợp")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(viewModel.onlyFavorites
                 ? "Hãy nhấn vào biểu tượng trái tim trên các món ăn để lưu lại vào đây."
                 : "Hãy thử tìm bằng tiếng Việt không dấu hoặc chọn nhóm món khác.")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            if viewModel.onlyFavorites {
                Button(action: { viewModel.onlyFavorites = false }) {
                    Text("Xem toàn bộ món ăn")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(AppColors.mintSurface)
                        .clipShape(Capsule())
                }
            } else if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Text("Xóa từ khóa tìm kiếm")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(AppColors.mintSurface)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }
}

// MARK: - Featured Food Card (Carousel)
private struct FeaturedFoodCard: View {
    let dish: VietnameseDishProfile
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .bottomLeading) {
                Image(dish.assetImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 260, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(dish.category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.softGreen)
                        .textCase(.uppercase)

                    Text(dish.vietnameseName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text("\(Int(dish.caloriesPerServing)) kcal")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("•")
                            .foregroundColor(.white.opacity(0.6))

                        Text("\(Int(dish.standardServingGrams))g")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(AppSpacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("featured_dish_\(dish.slug)")
    }
}

// MARK: - Food Catalog Card (Grid)
private struct FoodCatalogCard: View {
    let dish: VietnameseDishProfile
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with Favorite Button
                ZStack(alignment: .topTrailing) {
                    Image(dish.assetImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .clipped()

                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isFavorite ? Color(hex: "E97970") : AppColors.textPrimaryDark)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    .padding(8)
                    .accessibilityLabel(isFavorite ? "Bỏ yêu thích" : "Yêu thích")
                }

                // Details Content
                VStack(alignment: .leading, spacing: 4) {
                    // Category & reference code
                    HStack {
                        Text(dish.category)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppColors.primaryGreen)
                            .textCase(.uppercase)

                        Spacer()

                        Text("\(Int(dish.standardServingGrams))g")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Vietnamese Name
                    Text(dish.vietnameseName)
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    // English Name
                    Text(dish.englishName)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)

                    // Calories & Macros Summary
                    HStack(spacing: 4) {
                        Text("\(Int(dish.caloriesPerServing))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryGreen)
                        Text("kcal")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)

                        Spacer()

                        Text("P:\(Int(dish.proteinPerServing))g")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.proteinBlue)
                    }
                    .padding(.top, 4)
                }
                .padding(10)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("catalog_dish_\(dish.slug)")
        .accessibilityLabel("Món \(dish.vietnameseName)")
    }
}
