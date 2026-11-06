//
//  NutritionGoalsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical interface for personal nutrition target configuration.
//

import SwiftUI

public struct NutritionGoalsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onDismiss: () -> Void

    @State private var selectedGoal: DietaryGoal
    @State private var dailyCalories: Double
    @State private var isSaving: Bool = false
    @State private var showSaveSuccess: Bool = false

    public init(viewModel: ProfileViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        _selectedGoal = State(initialValue: viewModel.profile.goal)
        _dailyCalories = State(initialValue: viewModel.profile.dailyCalorieTarget)
    }

    // Calculated macros based on chosen calorie budget
    private var calculatedProteinGrams: Double {
        (dailyCalories * 0.25) / 4.0
    }
    private var calculatedCarbGrams: Double {
        (dailyCalories * 0.50) / 4.0
    }
    private var calculatedFatGrams: Double {
        (dailyCalories * 0.25) / 9.0
    }

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - 1. Botanical Header Illustration Card
                    headerBannerCard
                        .padding(.top, AppSpacing.sm)

                    // MARK: - 2. Dietary Goal Selector
                    dietaryGoalSection

                    // MARK: - 3. Daily Calorie Target Stepper
                    calorieTargetSection

                    // MARK: - 4. Macro Breakdown Cards
                    macroBreakdownSection

                    // MARK: - 5. Save Button
                    PrimaryButton("Lưu mục tiêu", icon: "checkmark", isLoading: isSaving) {
                        Task {
                            isSaving = true
                            await viewModel.updateProfile(
                                name: viewModel.profile.name,
                                goal: selectedGoal,
                                calories: dailyCalories
                            )
                            isSaving = false
                            showSaveSuccess = true
                            try? await Task.sleep(nanoseconds: 600_000_000)
                            onDismiss()
                        }
                    }
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(
                ZStack {
                    // Background
                    AppColors.canvasBackground.ignoresSafeArea()

                    Image("botanical_wallpaper")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.08)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            )
            .navigationTitle("Thiết lập mục tiêu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng", action: onDismiss)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerBannerCard: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 56, height: 56)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primary)
            }

            Text("Mục tiêu dinh dưỡng cá nhân")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Điều chỉnh thông tin theo nhu cầu và sở thích của bạn để NutriLens cá nhân hóa kế hoạch mỗi ngày.")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.sm)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.surfacePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var dietaryGoalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Mục tiêu thể trạng")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 8) {
                ForEach(DietaryGoal.allCases, id: \.self) { goal in
                    Button {
                        selectedGoal = goal
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            ZStack {
                                Circle()
                                    .stroke(selectedGoal == goal ? AppColors.primary : AppColors.border, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                if selectedGoal == goal {
                                    Circle()
                                        .fill(AppColors.primary)
                                        .frame(width: 10, height: 10)
                                }
                            }

                            Text(localizedGoal(goal))
                                .font(AppTypography.bodyBold)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Text(goalSubtitle(goal))
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(selectedGoal == goal ? AppColors.surfaceSecondary : AppColors.surfacePrimary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .stroke(selectedGoal == goal ? AppColors.primary : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var calorieTargetSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Năng lượng mỗi ngày")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(dailyCalories))")
                            .font(AppTypography.nutritionValueLarge)
                            .foregroundColor(AppColors.primary)
                        Text("kcal / ngày")
                            .font(AppTypography.subheadlineBold)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Text("Nhu cầu năng lượng cơ sở khuyến nghị")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        if dailyCalories > 1200 {
                            dailyCalories -= 50
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primary)
                    }
                    .accessibilityLabel("Giảm 50 kcal")

                    Button {
                        if dailyCalories < 4000 {
                            dailyCalories += 50
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primary)
                    }
                    .accessibilityLabel("Tăng 50 kcal")
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColors.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    private var macroBreakdownSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Tỷ lệ dinh dưỡng đa lượng dự kiến")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                MacroCard(
                    title: "Chất đạm",
                    subtitle: "Protein",
                    amount: "\(Int(calculatedProteinGrams))g",
                    ratio: "25%",
                    color: AppColors.proteinBlue,
                    icon: "atom"
                )

                MacroCard(
                    title: "Tinh bột",
                    subtitle: "Carbs",
                    amount: "\(Int(calculatedCarbGrams))g",
                    ratio: "50%",
                    color: AppColors.carbsOrange,
                    icon: "leaf.fill"
                )

                MacroCard(
                    title: "Chất béo",
                    subtitle: "Fat",
                    amount: "\(Int(calculatedFatGrams))g",
                    ratio: "25%",
                    color: AppColors.fatCoral,
                    icon: "drop.fill"
                )
            }
        }
    }

    private func localizedGoal(_ goal: DietaryGoal) -> String {
        switch goal {
        case .maintainWeight: return "Duy trì cân nặng"
        case .loseWeight: return "Giảm cân an toàn"
        case .gainMuscle: return "Tăng cơ săn chắc"
        case .balancedNutrition: return "Ăn uống lành mạnh"
        }
    }

    private func goalSubtitle(_ goal: DietaryGoal) -> String {
        switch goal {
        case .maintainWeight: return "Cân bằng năng lượng"
        case .loseWeight: return "-300 đến -500 kcal"
        case .gainMuscle: return "Tập trung Protein"
        case .balancedNutrition: return "Đầy đủ dưỡng chất"
        }
    }
}

private struct MacroCard: View {
    let title: String
    let subtitle: String
    let amount: String
    let ratio: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
                Spacer()
                Text(ratio)
                    .font(AppTypography.captionBold)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textTertiary)
            }

            Text(amount)
                .font(AppTypography.headlineBold)
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppColors.surfacePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
