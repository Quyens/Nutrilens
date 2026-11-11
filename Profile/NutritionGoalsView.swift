//
//  NutritionGoalsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical interface for personal nutrition target configuration with full wallpaper integration.
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
        ZStack(alignment: .top) {
            // MARK: - Full Botanical Wallpaper (Matching HomeView)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // MARK: - 0. Custom Top Bar (Safe below Dynamic Island)
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Thiết lập mục tiêu")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Ngân sách calo & đa lượng mỗi ngày")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Đóng")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.forestGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 54)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // MARK: - 1. Botanical Header Illustration Card
                        headerBannerCard
                            .padding(.top, 4)

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
                                try? await Task.sleep(nanoseconds: 400_000_000)
                                onDismiss()
                            }
                        }
                        .padding(.top, AppSpacing.xs)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerBannerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 58, height: 58)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(AppColors.primary)
            }

            Text("Mục tiêu dinh dưỡng cá nhân")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Điều chỉnh kế hoạch năng lượng và dưỡng chất phù hợp nhất với thể trạng và chế độ ăn của bạn.")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.sm)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var dietaryGoalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mục tiêu thể trạng")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedGoal == goal ? AppColors.surfaceSecondary : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedGoal == goal ? AppColors.primary : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    private var calorieTargetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Năng lượng mỗi ngày")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(dailyCalories))")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
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

                HStack(spacing: 10) {
                    Button {
                        if dailyCalories > 1200 {
                            dailyCalories -= 50
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primary)
                    }
                    .accessibilityLabel("Giảm 50 kcal")

                    Button {
                        if dailyCalories < 4000 {
                            dailyCalories += 50
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primary)
                    }
                    .accessibilityLabel("Tăng 50 kcal")
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    private var macroBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tỷ lệ dinh dưỡng đa lượng dự kiến")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            HStack(spacing: 8) {
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
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
