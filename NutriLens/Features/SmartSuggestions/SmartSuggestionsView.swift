//
//  SmartSuggestionsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Main user interface for personalized, explainable, offline-first smart meal suggestions.
//

import SwiftUI

public struct SmartSuggestionsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SmartSuggestionsViewModel

    public init(viewModel: SmartSuggestionsViewModel? = nil) {
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: AppEnvironment.live().makeSmartSuggestionsViewModel())
        }
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Botanical background wallpaper
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // 1. Dynamic Island Safe Top Nav Bar
                topNavBar

                // 2. Main Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Success / Error Banners
                        bannerNotifications

                        // Welcome & Botanical Header Card
                        welcomeHeaderCard

                        // Search Bar
                        searchSection

                        // Meal Category Pills (Sáng, Trưa, Tối, Phụ)
                        mealCategoryPillsSection

                        // Active Dietary Style Quick Selector
                        dietaryStyleFilterSection

                        // Suggestions Header & Count
                        suggestionsListHeader

                        // Suggestions List / Empty State / Loading State
                        if viewModel.isLoading {
                            loadingStateView
                        } else if viewModel.suggestions.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(viewModel.suggestions) { suggestion in
                                    SuggestionCardView(
                                        suggestion: suggestion,
                                        onToggleFavorite: {
                                            viewModel.toggleFavorite(for: suggestion)
                                        },
                                        onOpenExplanation: {
                                            viewModel.explanationSuggestion = suggestion
                                        },
                                        onOpenIngredients: {
                                            viewModel.ingredientReviewSuggestion = suggestion
                                        },
                                        onAddToPlan: {
                                            viewModel.addToPlanSuggestion = suggestion
                                        }
                                    )
                                }
                            }
                        }

                        // Bottom padding for clear scroll
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        // Sheets
        .sheet(item: $viewModel.explanationSuggestion) { suggestion in
            RecommendationExplanationSheet(suggestion: suggestion) {
                viewModel.explanationSuggestion = nil
            }
        }
        .sheet(item: $viewModel.ingredientReviewSuggestion) { suggestion in
            IngredientReviewSheet(
                suggestion: suggestion,
                userProfile: viewModel.userProfile
            ) {
                viewModel.ingredientReviewSuggestion = nil
            }
        }
        .sheet(item: $viewModel.addToPlanSuggestion) { suggestion in
            AddSuggestionToPlanSheet(
                suggestion: suggestion,
                initialDate: viewModel.targetDate,
                initialCategory: viewModel.selectedMealCategory
            ) { sugg, date, cat, multiplier, notes in
                viewModel.confirmAddToWeeklyPlan(
                    suggestion: sugg,
                    date: date,
                    category: cat,
                    multiplier: multiplier,
                    notes: notes
                )
            }
        }
        .sheet(isPresented: $viewModel.isShowingPreferencesSheet) {
            EditDietaryPreferencesSheet(
                initialProfile: viewModel.userProfile,
                onSave: { updatedProfile in
                    viewModel.saveDietaryProfile(updatedProfile)
                },
                onClear: {
                    viewModel.clearDietaryProfile()
                }
            )
        }
    }

    // MARK: - Subviews: Top Navigation Bar
    private var topNavBar: some View {
        HStack {
            Button(action: {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                    Text("Quay lại")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.85))
                .clipShape(Capsule())
            }

            Spacer()

            Text("Gợi ý món ăn")
                .font(.system(size: 17, weight: .bold, design: .serif))
                .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))

            Spacer()

            // Dietary Preferences Shortcut Button
            Button(action: {
                viewModel.isShowingPreferencesSheet = true
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Tùy chỉnh sở thích dinh dưỡng")
            .accessibilityIdentifier("open_dietary_preferences_button")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 54) // Dynamic Island safe clearance
        .padding(.bottom, 8)
    }

    // MARK: - Subviews: Notifications Banner
    @ViewBuilder
    private var bannerNotifications: some View {
        if let successMsg = viewModel.successMessage {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.forestGreen)
                Text(successMsg)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.forestGreen)
                Spacer()
                Button {
                    viewModel.successMessage = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.forestGreen)
                }
            }
            .padding(12)
            .background(AppColors.mintSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AppColors.softGreen, lineWidth: 1))
        }

        if let errorMsg = viewModel.errorMessage {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 0.85, green: 0.3, blue: 0.3))
                Text(errorMsg)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.85, green: 0.3, blue: 0.3))
                Spacer()
                Button {
                    viewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.85, green: 0.3, blue: 0.3))
                }
            }
            .padding(12)
            .background(Color(red: 1.0, green: 0.94, blue: 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Subviews: Welcome Header
    private var welcomeHeaderCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.mintSurface)
                    .frame(width: 46, height: 46)
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.forestGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Gợi ý dành cho bạn")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.textPrimary)
                Text("Khám phá món ngon phù hợp với sở thích, cân đối đa lượng và thực đơn tuần")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(1.5)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous).stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1))
    }

    // MARK: - Subviews: Search Bar
    private var searchSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14))

            TextField("Tìm món gợi ý, nguyên liệu, từ khóa...", text: $viewModel.searchText)
                .font(.system(size: 14))
                .onChange(of: viewModel.searchText) { _, newValue in
                    viewModel.updateSearchText(newValue)
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.updateSearchText("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Subviews: Meal Category Pills
    private var mealCategoryPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Tất cả"
                CategoryFilterPill(
                    title: "Tất cả bữa",
                    icon: "tray.full.fill",
                    isSelected: viewModel.selectedMealCategory == nil,
                    action: { viewModel.selectMealCategory(nil) }
                )

                // 4 PlannedMealCategories
                ForEach(PlannedMealCategory.allCases) { category in
                    CategoryFilterPill(
                        title: category.vietnameseName,
                        icon: category.systemIcon,
                        isSelected: viewModel.selectedMealCategory == category,
                        action: { viewModel.selectMealCategory(category) }
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Subviews: Dietary Style Quick Filter
    private var dietaryStyleFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // Favorite toggle pill
                Button {
                    viewModel.toggleFavoriteFilter()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.favoriteOnly ? "heart.fill" : "heart")
                            .font(.system(size: 11))
                        Text("Yêu thích")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(viewModel.favoriteOnly ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.favoriteOnly ? Color(red: 0.90, green: 0.30, blue: 0.35) : Color.white.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(viewModel.favoriteOnly ? Color.clear : AppColors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Dietary style pills
                ForEach(DietaryPreferenceType.allCases) { style in
                    let isSelected = viewModel.selectedDietaryStyle == style
                    Button {
                        viewModel.selectDietaryStyle(style)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: style.systemIcon)
                                .font(.system(size: 11))
                            Text(style.title)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(isSelected ? .white : AppColors.forestGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? AppColors.forestGreen : AppColors.mintSurface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isSelected ? Color.clear : AppColors.softGreen, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Subviews: Suggestions Header
    private var suggestionsListHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.forestGreen)
                Text("Món ăn đề xuất")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            Text("\(viewModel.suggestions.count) món phù hợp")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Subviews: Loading State
    private var loadingStateView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppColors.forestGreen)
            Text("Đang phân tích sở thích & tính toán gợi ý...")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Subviews: Empty State
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.mintSurface)
                    .frame(width: 64, height: 64)
                Image(systemName: "tray")
                    .font(.system(size: 26))
                    .foregroundColor(AppColors.forestGreen)
            }

            VStack(spacing: 4) {
                Text("Không tìm thấy món ăn phù hợp")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("Có thể bộ lọc dị ứng hoặc tiêu chí kiêng cữ hiện tại đang loại trừ các món ăn. Hãy thử điều chỉnh sở thích hoặc tắt bộ lọc tìm kiếm.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            Button {
                viewModel.selectedMealCategory = nil
                viewModel.selectedDietaryStyle = nil
                viewModel.favoriteOnly = false
                viewModel.updateSearchText("")
            } label: {
                Text("Xem tất cả gợi ý")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.forestGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

// MARK: - Category Filter Pill Helper
private struct CategoryFilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? AppColors.forestGreen : Color.white.opacity(0.9))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.02), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}
