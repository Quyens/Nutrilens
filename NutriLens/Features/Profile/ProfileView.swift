//
//  ProfileView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Profile Dashboard.
//

import SwiftUI

public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    private let onOpenSettings: () -> Void
    private let onOpenAccount: () -> Void

    @State private var showingNutritionGoalsSheet: Bool = false
    @State private var showingPersonalInfoSheet: Bool = false
    @State private var showingPreferencesSheet: Bool = false
    @State private var showingAboutSheet: Bool = false

    public init(
        viewModel: ProfileViewModel,
        onOpenSettings: @escaping () -> Void,
        onOpenAccount: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenSettings = onOpenSettings
        self.onOpenAccount = onOpenAccount
    }

    private var isGuest: Bool {
        viewModel.currentSession.isGuest
    }

    private var displayName: String {
        if isGuest {
            return "Khách NutriLens"
        }
        return viewModel.currentSession.user?.displayName ?? viewModel.profile.name
    }

    private var localizedGoal: String {
        switch viewModel.profile.goal {
        case .maintainWeight: return "Duy trì cân nặng"
        case .loseWeight: return "Giảm cân an toàn"
        case .gainMuscle: return "Tăng cơ săn chắc"
        case .balancedNutrition: return "Ăn uống lành mạnh"
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - 1. Profile Hero Card
                    BotanicalProfileHeader(
                        displayName: displayName,
                        isGuest: isGuest,
                        goalTitle: localizedGoal
                    )
                    .padding(.top, AppSpacing.sm)

                    // MARK: - 2. Featured Nutrition Goals Card
                    NutritionGoalsCard(
                        dailyCalories: viewModel.profile.dailyCalorieTarget,
                        dailyProteinGrams: viewModel.profile.dailyProteinTargetGrams,
                        dailyCarbGrams: viewModel.profile.dailyCarbTargetGrams,
                        dailyFatGrams: viewModel.profile.dailyFatTargetGrams,
                        onOpenEditor: {
                            showingNutritionGoalsSheet = true
                        }
                    )

                    // MARK: - 3. Unified Profile Menu Card
                    ProfileMenuCard(
                        onOpenPersonalInfo: {
                            showingPersonalInfoSheet = true
                        },
                        onOpenPreferences: {
                            showingPreferencesSheet = true
                        },
                        onOpenAccount: {
                            onOpenAccount()
                        },
                        onOpenSettings: {
                            onOpenSettings()
                        },
                        onOpenAbout: {
                            showingAboutSheet = true
                        }
                    )

                    // MARK: - 4. Subdued App Footer
                    VStack(spacing: 4) {
                        Text("NutriLens • AI Dinh Dưỡng Thuần Việt")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Phiên bản 1.0.0 (Build 2026.11)")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                }
                .padding(AppSpacing.screenHorizontal)
            }
            .background(
                ZStack {
                    AppColors.canvasBackground.ignoresSafeArea()

                    Image("botanical_wallpaper")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.10)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            )
            .navigationTitle("Hồ sơ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.forestGreen)
                    }
                    .accessibilityLabel("Mở Cài đặt ứng dụng")
                }
            }
            .sheet(isPresented: $showingNutritionGoalsSheet) {
                NutritionGoalsView(viewModel: viewModel) {
                    showingNutritionGoalsSheet = false
                }
            }
            .sheet(isPresented: $showingPersonalInfoSheet) {
                PersonalInfoSheet(profile: viewModel.profile) {
                    showingPersonalInfoSheet = false
                }
            }
            .sheet(isPresented: $showingPreferencesSheet) {
                PreferencesSheet {
                    showingPreferencesSheet = false
                }
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutSheet {
                    showingAboutSheet = false
                }
            }
            .task {
                await viewModel.loadProfile()
                if ProcessInfo.processInfo.arguments.contains("-startNutritionGoals") {
                    showingNutritionGoalsSheet = true
                }
            }
        }
    }
}

// MARK: - Supplementary Sheet Previews

private struct PersonalInfoSheet: View {
    let profile: UserProfile
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(spacing: AppSpacing.md) {
                    CardView {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Thông tin thể trạng")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            HStack {
                                Text("Tên hiển thị")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(profile.name)
                                    .font(AppTypography.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Divider()
                            HStack {
                                Text("Mục tiêu dinh dưỡng")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(profile.goal.rawValue)
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.lg)
            }
            .navigationTitle("Thông tin cá nhân")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong", action: onDismiss)
                        .foregroundColor(AppColors.primaryDark)
                }
            }
        }
    }
}

private struct PreferencesSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(spacing: AppSpacing.md) {
                    CardView {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            HStack(spacing: 8) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("Thực đơn & Dị ứng thực phẩm")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Text("NutriLens ưu tiên nhận diện món ăn Việt Nam truyền thống và hiện đại. Bạn có thể thiết lập cảnh báo dị ứng hoặc chế độ ăn đặc biệt trong các bản cập nhật sắp tới.")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(3)
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.lg)
            }
            .navigationTitle("Sở thích dinh dưỡng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong", action: onDismiss)
                        .foregroundColor(AppColors.primaryDark)
                }
            }
        }
    }
}

private struct AboutSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(AppColors.primary)

                        Text("NutriLens")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textPrimary)

                        Text("AI Dinh Dưỡng Món Việt • On-Device")
                            .font(AppTypography.captionBold)
                            .foregroundColor(AppColors.primaryDark)
                    }
                    .padding(.top, AppSpacing.lg)

                    CardView {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Về ứng dụng")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("NutriLens kết hợp công nghệ Trí tuệ Nhân tạo on-device (Core ML) và cơ sở dữ liệu dinh dưỡng món ăn Việt Nam độc quyền nhằm giúp người dùng theo dõi calo, cân bằng đa lượng và xây dựng lối sống lành mạnh bền vững.")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.screenHorizontal)
            }
            .navigationTitle("Giới thiệu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Đóng", action: onDismiss)
                        .foregroundColor(AppColors.primaryDark)
                }
            }
        }
    }
}
