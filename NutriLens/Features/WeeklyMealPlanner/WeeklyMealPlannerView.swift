//
//  WeeklyMealPlannerView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Main interactive screen for the Weekly Meal Planner (Phase 04).
//

import SwiftUI

public struct WeeklyMealPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: WeeklyMealPlannerViewModel
    @State private var isShowingSuggestionsSheet: Bool = false
    @State private var suggestionTargetCategory: PlannedMealCategory? = nil

    public init(viewModel: WeeklyMealPlannerViewModel? = nil) {
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: WeeklyMealPlannerViewModel(environment: .live()))
        }
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Botanical Canvas
            AppColors.canvasBackground.ignoresSafeArea()

            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.md) {
                        // Week Range Navigator Strip
                        weekNavigationHeader

                        // 7-Day Monday-to-Sunday Strip
                        WeeklyCalendarStripView(viewModel: viewModel)

                        // Daily Overview Banner
                        dailyOverviewCard

                        // 4 Meal Category Sections
                        mealCategorySection(.breakfast)
                        mealCategorySection(.lunch)
                        mealCategorySection(.dinner)
                        mealCategorySection(.snack)
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
        }
        .task {
            await viewModel.loadWeeklyPlan()
        }
        .sheet(isPresented: $viewModel.isShowingAddMealSheet) {
            AddPlannedMealSheet(
                initialDate: viewModel.selectedDate,
                initialCategory: viewModel.presetCategoryForAdd ?? .lunch
            ) { newMeal in
                Task { await viewModel.saveMeal(newMeal) }
            }
            .environmentObject(environment)
        }
        .sheet(item: $viewModel.selectedMealForDetail) { meal in
            PlannedMealDetailSheet(
                meal: meal,
                onLogToDiary: {
                    viewModel.mealToLogToDiary = meal
                },
                onMarkSkipped: {
                    Task { await viewModel.markMealSkipped(meal) }
                },
                onRestore: {
                    Task { await viewModel.restorePlannedStatus(meal) }
                },
                onDuplicateToTomorrow: {
                    Task { await viewModel.duplicateMealToTomorrow(meal) }
                },
                onEdit: {
                    viewModel.mealToEdit = meal
                },
                onDelete: {
                    Task { await viewModel.deleteMeal(meal) }
                }
            )
        }
        .sheet(item: $viewModel.mealToEdit) { meal in
            AddPlannedMealSheet(
                initialDate: meal.scheduledDate,
                initialCategory: meal.mealCategory,
                existingMeal: meal
            ) { updatedMeal in
                Task { await viewModel.saveMeal(updatedMeal) }
            }
            .environmentObject(environment)
        }
        .sheet(isPresented: $viewModel.isShowingCopyDaySheet) {
            CopyDayPlanSheet(
                sourceDate: viewModel.selectedDate,
                mealsCount: viewModel.mealsForSelectedDate.count
            ) { source, target, mode in
                Task { await viewModel.copyDay(from: source, to: target, mode: mode) }
            }
        }
        .fullScreenCover(isPresented: $isShowingSuggestionsSheet, onDismiss: {
            Task { await viewModel.loadWeeklyPlan() }
        }) {
            SmartSuggestionsView(viewModel: AppEnvironment.live().makeSmartSuggestionsViewModel(initialCategory: suggestionTargetCategory, initialDate: viewModel.selectedDate))
        }
        .sheet(item: $viewModel.mealToLogToDiary) { meal in
            LogPlannedMealConfirmationSheet(plannedMeal: meal) { items, date, type, notes in
                Task {
                    await viewModel.logMealToDiary(
                        plannedMeal: meal,
                        actualFoodItems: items,
                        loggedDate: date,
                        mealType: type,
                        notes: notes
                    )
                }
            }
        }
        .alert(viewModel.alertMessage ?? "Thông báo", isPresented: $viewModel.showAlert) {
            Button("Đóng", role: .cancel) {}
        }
    }

    // MARK: - Top Nav Bar
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

            Text("Kế hoạch thực đơn")
                .font(.system(size: 17, weight: .bold, design: .serif))
                .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))

            Spacer()

            // Copy Day Button
            Button(action: {
                viewModel.isShowingCopyDaySheet = true
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Sao chép thực đơn ngày")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 54) // Dynamic Island safe
        .padding(.bottom, 8)
    }

    // MARK: - Week Navigation Header
    private var weekNavigationHeader: some View {
        HStack {
            // Previous Week
            Button(action: {
                viewModel.goToPreviousWeek()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }

            Spacer()

            // Week Range Label
            Text(viewModel.currentWeekRangeString)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            // Today button if not current week
            if !viewModel.isCurrentWeekToday {
                Button(action: {
                    viewModel.goToToday()
                }) {
                    Text("Hôm nay")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.mintSurface)
                        .clipShape(Capsule())
                }
            }

            // Next Week
            Button(action: {
                viewModel.goToNextWeek()
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 4)
    }

    // MARK: - Daily Overview Card
    private var dailyOverviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.calendarHelper.vietnameseFullDate(for: viewModel.selectedDate))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Kế hoạch dinh dưỡng dự tính trong ngày")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Completed vs Planned badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text("\(viewModel.completedMealsCountForSelectedDate)/\(viewModel.totalMealsCountForSelectedDate) bữa")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.mintSurface)
                .foregroundColor(AppColors.primaryGreen)
                .clipShape(Capsule())
            }

            Divider()
                .background(Color(red: 0.90, green: 0.93, blue: 0.91))

            // Nutrition estimates
            let snap = viewModel.dailyPlannedNutrition
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(Int(snap.calories))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                    Text("kcal dự tính")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    OverviewNutrientItem(title: "Đạm", value: "\(Int(snap.proteinGrams))g", color: AppColors.proteinBlue)
                    OverviewNutrientItem(title: "Carb", value: "\(Int(snap.carbGrams))g", color: AppColors.carbOrange)
                    OverviewNutrientItem(title: "Béo", value: "\(Int(snap.fatGrams))g", color: AppColors.fatRed)
                }
            }

            // Distinguish from actual diary
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                Text("Dự tính thực đơn không tự động cộng vào calo thực tế cho đến khi bạn xác nhận 'Đã ăn'.")
                    .font(.system(size: 10))
            }
            .foregroundColor(AppColors.textSecondary)
            .padding(.top, 2)
        }
        .padding(14)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - Meal Category Section
    private func mealCategorySection(_ category: PlannedMealCategory) -> some View {
        let meals = viewModel.mealsForSelectedDate(category: category)

        return VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: category.systemIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)

                    Text(category.vietnameseName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                Button {
                    viewModel.openAddMeal(category: category)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Thêm món")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryGreen)
                }
                .accessibilityIdentifier("add_meal_to_\(category.rawValue.lowercased())")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)

            if meals.isEmpty {
                HStack(spacing: 8) {
                    // Empty State Button: Lên thực đơn
                    Button {
                        viewModel.openAddMeal(category: category)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Lên thực đơn")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundColor(Color(red: 0.82, green: 0.88, blue: 0.84))
                        )
                    }
                    .buttonStyle(.plain)

                    // Smart Suggestion Button
                    Button {
                        suggestionTargetCategory = category
                        isShowingSuggestionsSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .bold))
                            Text("Gợi ý")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(AppColors.forestGreen)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColors.mintSurface)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .stroke(AppColors.softGreen, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("suggest_button_for_\(category.rawValue.lowercased())")
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(meals) { meal in
                        PlannedMealCardView(
                            meal: meal,
                            onSelect: {
                                viewModel.selectedMealForDetail = meal
                            },
                            onLogToDiary: {
                                viewModel.mealToLogToDiary = meal
                            },
                            onMarkSkipped: {
                                Task { await viewModel.markMealSkipped(meal) }
                            },
                            onRestore: {
                                Task { await viewModel.restorePlannedStatus(meal) }
                            },
                            onDuplicateToTomorrow: {
                                Task { await viewModel.duplicateMealToTomorrow(meal) }
                            },
                            onEdit: {
                                viewModel.mealToEdit = meal
                            },
                            onDelete: {
                                Task { await viewModel.deleteMeal(meal) }
                            }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
        .padding(.top, 4)
    }
}

private struct OverviewNutrientItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

