//
//  OnboardingView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background ambient radial glow
                AppColors.background.ignoresSafeArea()
                AppColors.subtleGlowGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.xl) {
                            // MARK: - Hero Branding Header
                            HeroHeaderView()

                            // MARK: - Health Goal Selection
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                HStack {
                                    Text("What is your primary goal?")
                                        .font(AppTypography.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Text("Step 1 of 2")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .padding(.horizontal, AppSpacing.xs)

                                ForEach(DietaryGoal.allCases, id: \.self) { goal in
                                    GoalCardRow(
                                        goal: goal,
                                        isSelected: viewModel.selectedGoal == goal,
                                        action: {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                                viewModel.selectedGoal = goal
                                            }
                                        }
                                    )
                                }
                            }

                            // MARK: - Calorie Target Interactive Dial Card
                            CalorieTargetCard(
                                targetCalories: $viewModel.dailyCalorieTarget,
                                goal: viewModel.selectedGoal
                            )
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xxl + 40)
                    }

                    // MARK: - Floating Bottom Action Dock
                    VStack(spacing: AppSpacing.xs) {
                        PrimaryButton("Start My Healthy Journey", icon: "sparkles", isLoading: viewModel.isSaving) {
                            viewModel.completeOnboarding()
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.primary)
                            Text("100% On-Device AI • Your nutritional data never leaves your device")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.md)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    )
                }
            }
        }
    }
}

// MARK: - Hero Header Subcomponent
private struct HeroHeaderView: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Floating concentric glowing badge
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 90, height: 90)

                Circle()
                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 66, height: 66)
                    .shadow(color: AppColors.primary.opacity(0.35), radius: 10, y: 5)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, AppSpacing.sm)

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text("Nutri")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Lens")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryGradient)
                }

                Text("Vietnamese Food Recognition & Clean Nutrition Tracking")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }

            // Highlighting Tags
            HStack(spacing: AppSpacing.xs) {
                FeatureBadge(title: "Món Việt AI", icon: "camera.fill")
                FeatureBadge(title: "Macro Accuracy", icon: "chart.bar.fill")
                FeatureBadge(title: "SwiftData Local", icon: "internaldrive.fill")
            }
        }
    }
}

private struct FeatureBadge: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.primary)
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.border.opacity(0.3), lineWidth: 0.8))
        .shadow(color: Color.black.opacity(0.02), radius: 4, y: 2)
    }
}

// MARK: - Goal Option Row with Rich Metadata
private struct GoalCardRow: View {
    let goal: DietaryGoal
    let isSelected: Bool
    let action: () -> Void

    private var goalMetadata: (icon: String, subtitle: String, color: Color) {
        switch goal {
        case .maintainWeight:
            return ("scalemass.fill", "Keep current weight with balanced energy intake", AppColors.info)
        case .loseWeight:
            return ("flame.fill", "Controlled calorie deficit with sustained satiety", Color.orange)
        case .gainMuscle:
            return ("figure.strengthtraining.traditional", "Hypertrophy focus with high protein density", AppColors.protein)
        case .balancedNutrition:
            return ("heart.fill", "Wholesome Vietnamese dishes & micronutrients", AppColors.primary)
        }
    }

    var body: some View {
        Button(action: action) {
            CardView(padding: AppSpacing.md, cornerRadius: AppRadius.lg, isSelected: isSelected) {
                HStack(spacing: AppSpacing.md) {
                    // Icon squircle
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(isSelected ? goalMetadata.color.opacity(0.18) : AppColors.background)
                            .frame(width: 44, height: 44)

                        Image(systemName: goalMetadata.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isSelected ? goalMetadata.color : AppColors.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.rawValue)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text(goalMetadata.subtitle)
                            .font(AppTypography.footnote)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Checkmark indicator
                    ZStack {
                        Circle()
                            .fill(isSelected ? AnyShapeStyle(AppColors.primaryGradient) : AnyShapeStyle(Color.clear))
                            .frame(width: 26, height: 26)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(AppColors.border.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calorie Target Interactive Dial Card
private struct CalorieTargetCard: View {
    @Binding var targetCalories: Double
    let goal: DietaryGoal

    var body: some View {
        CardView(padding: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Recommended Daily Budget")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.textSecondary)

                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(targetCalories))")
                                .font(AppTypography.metricLarge)
                                .foregroundColor(AppColors.primaryDark)
                            Text("kcal / day")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    // Quick bump buttons
                    HStack(spacing: AppSpacing.xs) {
                        QuickBumpButton(title: "-100") {
                            targetCalories = max(1200, targetCalories - 100)
                        }
                        QuickBumpButton(title: "+100") {
                            targetCalories = min(4000, targetCalories + 100)
                        }
                    }
                }

                Slider(
                    value: $targetCalories,
                    in: 1200...4000,
                    step: 50
                )
                .tint(AppColors.primary)

                HStack {
                    Text("1,200 kcal")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                    Text("Ideal for \(goal.rawValue)")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.primary)
                    Spacer()
                    Text("4,000 kcal")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }
}

private struct QuickBumpButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        }) {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.primarySubtle)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.primary.opacity(0.3), lineWidth: 1))
        }
    }
}
