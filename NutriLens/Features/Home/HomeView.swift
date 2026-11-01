//
//  HomeView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let onScanTapped: () -> Void
    private let onLogManualTapped: () -> Void
    private let onQuickLogDish: ((FoodItem) -> Void)?

    public init(
        viewModel: HomeViewModel,
        onScanTapped: @escaping () -> Void,
        onLogManualTapped: @escaping () -> Void,
        onQuickLogDish: ((FoodItem) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onScanTapped = onScanTapped
        self.onLogManualTapped = onLogManualTapped
        self.onQuickLogDish = onQuickLogDish
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background & ambient glow
                AppColors.background.ignoresSafeArea()
                AppColors.subtleGlowGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Top Greeting & Streak Bar
                        UserGreetingHeader(profile: viewModel.userProfile)

                        switch viewModel.state {
                        case .idle, .loading:
                            LoadingView("Refreshing nutrition metrics...")
                                .frame(height: 280)

                        case .failure(let error):
                            ErrorStateView(
                                title: "Could Not Update Dashboard",
                                message: error.localizedDescription
                            ) {
                                Task { await viewModel.loadDashboard() }
                            }

                        case .success(let summary):
                            // 1. Hero Calorie Dial & Progress Card
                            HeroCalorieDialCard(
                                summary: summary,
                                onScan: onScanTapped
                            )

                            // 2. Macronutrient Triple Gauge Cards
                            MacroTrioSection(summary: summary)

                            // 3. Quick Action Dual Banners
                            InteractiveQuickActions(
                                onScan: onScanTapped,
                                onManual: onLogManualTapped
                            )

                            // 4. Quick Vietnamese Food Suggestions & Today's Log
                            TodayMealLogSection(
                                meals: viewModel.todaysMeals,
                                onScanNewMeal: onScanTapped,
                                onManualLog: onLogManualTapped,
                                onQuickAddSample: { dish in
                                    if let onQuickLogDish {
                                        onQuickLogDish(dish)
                                    }
                                    Task {
                                        try? await Task.sleep(nanoseconds: 200_000_000)
                                        await viewModel.loadDashboard()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, 120) // Clean clearance above TabBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primaryGradient)
                                .frame(width: 22, height: 22)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("NutriLens")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onLogManualTapped) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.primary)
                    }
                    .accessibilityLabel("Quick Add Meal")
                }
            }
            .refreshable {
                await viewModel.loadDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
        }
    }
}

// MARK: - Header with Greeting & Day Indicator
private struct UserGreetingHeader: View {
    let profile: UserProfile

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("TODAY'S OVERVIEW")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
                    .tracking(1)

                Text("Hello, \(profile.name) 👋")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            // Healthy streak pill
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
                Text("Day 1")
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.border.opacity(0.3), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .padding(.top, AppSpacing.xs)
    }
}

// MARK: - Hero Calorie Dial & Progress Card
private struct HeroCalorieDialCard: View {
    let summary: NutritionSummary
    let onScan: () -> Void

    var body: some View {
        CardView(padding: AppSpacing.lg, cornerRadius: AppRadius.xl) {
            VStack(spacing: AppSpacing.md) {
                HStack(alignment: .center, spacing: AppSpacing.lg) {
                    // Circular Dial Gauge
                    ZStack {
                        Circle()
                            .stroke(AppColors.primaryLight.opacity(0.25), lineWidth: 12)
                            .frame(width: 104, height: 104)

                        Circle()
                            .trim(from: 0, to: min(CGFloat(summary.calorieProgress), 1.0))
                            .stroke(
                                AppColors.primaryGradient,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 104, height: 104)
                            .shadow(color: AppColors.primary.opacity(0.25), radius: 6, x: 0, y: 2)

                        VStack(spacing: 0) {
                            Text("\(Int(summary.calorieProgress * 100))%")
                                .font(AppTypography.metricMedium)
                                .foregroundColor(AppColors.primaryDark)
                            Text("GOAL")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textTertiary)
                                .tracking(0.5)
                        }
                    }

                    // Stat Breakdown
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Remaining Calories")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(Int(summary.remainingCalories))")
                                    .font(AppTypography.metricLarge)
                                    .foregroundColor(AppColors.primaryDark)
                                Text("kcal")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        Divider()

                        HStack(spacing: AppSpacing.md) {
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Consumed")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textTertiary)
                                Text("\(Int(summary.consumedCalories)) kcal")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Budget")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textTertiary)
                                Text("\(Int(summary.targetCalories)) kcal")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Macronutrient Triple Cards
private struct MacroTrioSection: View {
    let summary: NutritionSummary

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            MacroProgressCard(
                title: "Protein",
                icon: "bolt.fill",
                consumed: summary.consumedProteinGrams,
                target: summary.targetProteinGrams,
                color: AppColors.protein
            )
            MacroProgressCard(
                title: "Carbs",
                icon: "leaf.fill",
                consumed: summary.consumedCarbGrams,
                target: summary.targetCarbGrams,
                color: AppColors.carbs
            )
            MacroProgressCard(
                title: "Fat",
                icon: "drop.fill",
                consumed: summary.consumedFatGrams,
                target: summary.targetFatGrams,
                color: AppColors.fat
            )
        }
    }
}

private struct MacroProgressCard: View {
    let title: String
    let icon: String
    let consumed: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.0)
    }

    var body: some View {
        CardView(padding: AppSpacing.sm + 2, cornerRadius: AppRadius.md) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                    Text(title)
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textSecondary)
                }

                Text("\(Int(consumed))g")
                    .font(AppTypography.title3)
                    .foregroundColor(color)

                // Tiny progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.18))
                            .frame(height: 5)
                        Capsule()
                            .fill(color)
                            .frame(width: max(geo.size.width * CGFloat(progress), 4), height: 5)
                    }
                }
                .frame(height: 5)

                Text("Target \(Int(target))g")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Interactive Quick Action Cards
private struct InteractiveQuickActions: View {
    let onScan: () -> Void
    let onManual: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Main AI Scanner Banner
            Button(action: {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                onScan()
            }) {
                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("Scan Dish")
                                .font(AppTypography.headline)
                                .foregroundColor(.white)
                            Text("AI")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(AppColors.primaryDark)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        Text("Phở, Cơm Tấm, Bún...")
                            .font(AppTypography.caption)
                            .foregroundColor(Color.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AnyShapeStyle(AppColors.primaryGradient))
                )
                .shadow(color: AppColors.primary.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            // Manual Entry Button
            Button(action: {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                onManual()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                    Text("Manual")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(width: 80)
                .padding(.vertical, AppSpacing.md - 2)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Today's Meals Section with Quick Add chips
private struct TodayMealLogSection: View {
    let meals: [MealRecord]
    let onScanNewMeal: () -> Void
    let onManualLog: () -> Void
    let onQuickAddSample: (FoodItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Today's Meals")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                if !meals.isEmpty {
                    Text("\(meals.count) logged")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            if meals.isEmpty {
                CardView(padding: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primarySubtle)
                                .frame(width: 60, height: 60)

                            Image(systemName: "fork.knife")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(spacing: 3) {
                            Text("No Meals Logged Yet")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Tap to quick-log a Vietnamese favorite or scan your dish:")
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Vietnamese Quick-Add suggestions
                        HStack(spacing: AppSpacing.xs) {
                            QuickFoodChip(title: "🍲 Phở Bò (480 kcal)") {
                                onQuickAddSample(
                                    FoodItem(
                                        name: "Vietnamese Beef Pho",
                                        vietnameseName: "Phở Bò Tái",
                                        confidence: 0.96,
                                        servingSizeGrams: 450,
                                        calories: 480,
                                        proteinGrams: 32,
                                        carbGrams: 62,
                                        fatGrams: 12,
                                        fiberGrams: 3
                                    )
                                )
                            }
                            QuickFoodChip(title: "🍛 Cơm Tấm (620 kcal)") {
                                onQuickAddSample(
                                    FoodItem(
                                        name: "Broken Rice Grilled Pork",
                                        vietnameseName: "Cơm Tấm Sườn Nướng",
                                        confidence: 0.93,
                                        servingSizeGrams: 400,
                                        calories: 620,
                                        proteinGrams: 38,
                                        carbGrams: 75,
                                        fatGrams: 18,
                                        fiberGrams: 4
                                    )
                                )
                            }
                        }
                        .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(meals) { meal in
                    MealRowCard(meal: meal)
                }
            }
        }
    }
}

private struct QuickFoodChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            action()
        }) {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.primaryDark)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppColors.primarySubtle)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.primary.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct MealRowCard: View {
    let meal: MealRecord

    var body: some View {
        CardView(padding: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primarySubtle)
                        .frame(width: 44, height: 44)

                    Image(systemName: meal.mealType.systemIcon)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(meal.items.map(\.vietnameseName).joined(separator: ", "))
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(meal.mealType.rawValue)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("•")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                        Text(meal.timestamp, format: .dateTime.hour().minute())
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.totalCalories)) kcal")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryDark)

                    Text("P: \(Int(meal.totalProteinGrams))g • C: \(Int(meal.totalCarbGrams))g")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }
}
