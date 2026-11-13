//
//  MyFoodsAndRecipesView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Personal Food Library & Recipe Management Hub.
//

import SwiftUI

public struct MyFoodsAndRecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: MyFoodsAndRecipesViewModel

    public init(viewModel: MyFoodsAndRecipesViewModel? = nil) {
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            // Placeholder, real init in onAppear if needed
            _viewModel = StateObject(wrappedValue: MyFoodsAndRecipesViewModel(
                getCustomFoodsUseCase: GetCustomFoodsUseCase(repository: MockCustomFoodRepository()),
                saveCustomFoodUseCase: SaveCustomFoodUseCase(repository: MockCustomFoodRepository()),
                deleteCustomFoodUseCase: DeleteCustomFoodUseCase(repository: MockCustomFoodRepository()),
                getRecipesUseCase: GetRecipesUseCase(repository: MockRecipeRepository()),
                saveRecipeUseCase: SaveRecipeUseCase(repository: MockRecipeRepository()),
                deleteRecipeUseCase: DeleteRecipeUseCase(repository: MockRecipeRepository()),
                logMealUseCase: LogMealUseCase(mealRepository: MealRepository())
            ))
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
                // Top Custom Navigation Bar (Dynamic Island Safe)
                topBar
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 52)
                    .padding(.bottom, 8)

                // Segmented Tabs: Món của bạn vs Công thức
                segmentedTabSection
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, 8)

                // Search & Filter Section
                searchAndFilterSection
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, 12)

                // Main Content List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        if viewModel.selectedTab == .customFoods {
                            customFoodsList
                        } else {
                            recipesList
                        }

                        Color.clear.frame(height: 50)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }

            // Toast Message Banner
            if let toast = viewModel.toastMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toast)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryGreen)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.25), value: viewModel.toastMessage)
            }
        }
        .fullScreenCover(item: $viewModel.selectedFoodForDetail) { food in
            CustomFoodDetailView(
                food: food,
                onFoodDeleted: {
                    viewModel.loadData()
                },
                onQuickLog: { _ in
                    viewModel.loadData()
                }
            )
        }
        .fullScreenCover(item: $viewModel.selectedRecipeForDetail) { recipe in
            RecipeDetailView(
                recipe: recipe,
                onRecipeDeleted: {
                    viewModel.loadData()
                },
                onQuickLog: { _, _ in
                    viewModel.loadData()
                }
            )
        }
        .sheet(isPresented: $viewModel.isPresentingCreateFood) {
            CreateEditCustomFoodView { newFood in
                viewModel.loadData()
            }
        }
        .sheet(isPresented: $viewModel.isPresentingCreateRecipe) {
            CreateEditRecipeView { newRecipe in
                viewModel.loadData()
            }
        }
        .onAppear {
            setupLiveViewModel()
            viewModel.loadData()
        }
    }

    private func setupLiveViewModel() {
        // Wire live environment dependencies
        let vm = MyFoodsAndRecipesViewModel(
            getCustomFoodsUseCase: environment.getCustomFoodsUseCase,
            saveCustomFoodUseCase: environment.saveCustomFoodUseCase,
            deleteCustomFoodUseCase: environment.deleteCustomFoodUseCase,
            getRecipesUseCase: environment.getRecipesUseCase,
            saveRecipeUseCase: environment.saveRecipeUseCase,
            deleteRecipeUseCase: environment.deleteRecipeUseCase,
            logMealUseCase: environment.logMealUseCase
        )
        // Copy current tab selection if already chosen
        vm.selectedTab = viewModel.selectedTab
        // We can reload using the newly wired use cases
        vm.loadData()
    }

    // MARK: - Top Navigation Bar
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Khám phá")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(AppColors.primaryGreen)
            }

            Spacer()

            Text("Món ăn & Công thức")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Menu {
                Button {
                    viewModel.isPresentingCreateFood = true
                } label: {
                    Label("Tạo món ăn riêng", systemImage: "plus.circle")
                }

                Button {
                    viewModel.isPresentingCreateRecipe = true
                } label: {
                    Label("Tạo công thức mới", systemImage: "book.closed")
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
    }

    // MARK: - Segmented Tab Section
    private var segmentedTabSection: some View {
        HStack(spacing: 8) {
            tabButton(
                title: "Món của bạn (\(viewModel.customFoods.count))",
                tab: .customFoods
            )
            tabButton(
                title: "Công thức (\(viewModel.recipes.count))",
                tab: .recipes
            )
        }
        .padding(4)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func tabButton(title: String, tab: PersonalLibraryTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedTab = tab
            }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? AnyView(AppColors.primaryGreen)
                    : AnyView(Color.clear)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Search & Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 10) {
            // Search Bar + Favorite Toggle
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.primaryGreen)

                    TextField(
                        viewModel.selectedTab == .customFoods ? "Tìm món ăn theo tên, thương hiệu..." : "Tìm công thức, nguyên liệu...",
                        text: $viewModel.searchQuery
                    )
                    .font(.system(size: 13))

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                // Favorite Only Star Button
                Button {
                    withAnimation {
                        viewModel.showFavoritesOnly.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(viewModel.showFavoritesOnly ? Color(hex: "E04F5F") : AppColors.textSecondary)
                        .padding(9)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(viewModel.showFavoritesOnly ? Color(hex: "E04F5F") : AppColors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Category Chips for Custom Foods
            if viewModel.selectedTab == .customFoods && viewModel.availableFoodCategories.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(viewModel.availableFoodCategories, id: \.self) { cat in
                            Button {
                                viewModel.selectedCategory = cat
                            } label: {
                                Text(cat)
                                    .font(.system(size: 11, weight: viewModel.selectedCategory == cat ? .bold : .medium))
                                    .foregroundColor(viewModel.selectedCategory == cat ? .white : AppColors.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        viewModel.selectedCategory == cat
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
            }
        }
    }

    // MARK: - Custom Foods List
    private var customFoodsList: some View {
        Group {
            if viewModel.filteredCustomFoods.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.primaryGreen.opacity(0.6))

                    Text(viewModel.searchQuery.isEmpty ? "Chưa có món ăn riêng nào" : "Không tìm thấy món phù hợp")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(viewModel.searchQuery.isEmpty ? "Tạo món ăn riêng để dễ dàng lưu lại thông tin calo và vi chất của những món bạn thường ăn." : "Thử tìm kiếm với từ khóa khác hoặc tạo món mới.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button {
                        viewModel.isPresentingCreateFood = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Tạo món ăn riêng ngay")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryGreen)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                ForEach(viewModel.filteredCustomFoods) { food in
                    CustomFoodCardView(
                        food: food,
                        onSelect: {
                            viewModel.selectedFoodForDetail = food
                        },
                        onToggleFavorite: {
                            viewModel.toggleFavorite(for: food)
                        },
                        onQuickLog: {
                            viewModel.quickLogFoodToDiary(food: food)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Recipes List
    private var recipesList: some View {
        Group {
            if viewModel.filteredRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.primaryGreen.opacity(0.6))

                    Text(viewModel.searchQuery.isEmpty ? "Chưa có công thức nào" : "Không tìm thấy công thức phù hợp")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(viewModel.searchQuery.isEmpty ? "Tạo công thức riêng từ nhiều nguyên liệu, tự động tính tổng calo và chia đều theo khẩu phần." : "Thử tìm kiếm với tên công thức hoặc nguyên liệu khác.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button {
                        viewModel.isPresentingCreateRecipe = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Tạo công thức mới ngay")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryGreen)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                ForEach(viewModel.filteredRecipes) { recipe in
                    RecipeCardView(
                        recipe: recipe,
                        onSelect: {
                            viewModel.selectedRecipeForDetail = recipe
                        },
                        onToggleFavorite: {
                            viewModel.toggleFavorite(for: recipe)
                        },
                        onQuickLog: {
                            viewModel.quickLogRecipeToDiary(recipe: recipe, servings: 1.0)
                        }
                    )
                }
            }
        }
    }
}
