//
//  ProfileView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    private let onOpenSettings: () -> Void
    private let onOpenAccount: () -> Void

    public init(
        viewModel: ProfileViewModel,
        onOpenSettings: @escaping () -> Void,
        onOpenAccount: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenSettings = onOpenSettings
        self.onOpenAccount = onOpenAccount
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Avatar Header
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(AppColors.primary)

                        Text(viewModel.profile.name)
                            .font(AppTypography.title2)
                            .foregroundColor(AppColors.textPrimary)

                        Text(viewModel.profile.goal.rawValue)
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.primaryDark)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 4)
                            .background(AppColors.primarySubtle)
                            .clipShape(Capsule())
                    }
                    .padding(.top, AppSpacing.md)

                    // Daily Goals Card
                    CardView {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Nutritional Targets")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            TargetRow(title: "Daily Calories", value: "\(Int(viewModel.profile.dailyCalorieTarget)) kcal")
                            TargetRow(title: "Target Protein", value: "\(Int(viewModel.profile.dailyProteinTargetGrams)) g")
                            TargetRow(title: "Target Carbs", value: "\(Int(viewModel.profile.dailyCarbTargetGrams)) g")
                            TargetRow(title: "Target Fat", value: "\(Int(viewModel.profile.dailyFatTargetGrams)) g")
                        }
                    }

                    // Account & Security Card
                    CardView {
                        VStack(spacing: 0) {
                            Button(action: onOpenAccount) {
                                HStack {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Tài khoản & Xác thực")
                                                .font(AppTypography.subheadline)
                                                .foregroundColor(AppColors.textPrimary)
                                            Text(viewModel.currentSession.isGuest ? "Chế độ Khách (Guest)" : (viewModel.currentSession.user?.email ?? "Chưa đăng nhập"))
                                                .font(AppTypography.caption)
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    } icon: {
                                        Image(systemName: "person.badge.shield.checkmark.fill")
                                            .foregroundColor(AppColors.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                        }
                    }

                    // Preferences and Settings Link
                    CardView {
                        VStack(spacing: 0) {
                            Button(action: onOpenSettings) {
                                HStack {
                                    Label("App Settings & Privacy", systemImage: "gearshape.fill")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(Color.clear)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadProfile()
            }
        }
    }
}

private struct TargetRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.subheadlineBold)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}
