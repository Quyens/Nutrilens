//
//  ProfileView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Profile Dashboard with full native wallpaper integration.
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
            ZStack(alignment: .top) {
                // MARK: - Full Botanical Wallpaper (Matching HomeView)
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    // MARK: - 0. Custom Top Bar (Safe below Dynamic Island)
                    customTopBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, 52)
                        .padding(.bottom, 6)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // MARK: - 1. Personal Identity Hero Card
                            personalHeroCard

                            // MARK: - 2. Featured Nutrition Targets Card
                            nutritionTargetsCard

                            // MARK: - 3. Quick Health Metrics Widgets
                            quickMetricsSection

                            // MARK: - 4. Grouped Profile Settings Cards
                            accountAndDataCard
                            appAndAboutCard

                            // MARK: - 5. Footer
                            VStack(spacing: 4) {
                                Text("NutriLens • AI Dinh Dưỡng Thuần Việt")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("Phiên bản 1.0.0 (Build 2026.11)")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 130) // Generous clearance for floating tab bar
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, 6)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarHidden(true)
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

    // MARK: - Subviews

    private var customTopBar: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Hồ sơ cá nhân")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Trung tâm sức khỏe & mục tiêu")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Button(action: onOpenSettings) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.forestGreen)
                }
            }
            .accessibilityLabel("Mở Cài đặt ứng dụng")
        }
        .padding(.vertical, 4)
    }

    private var personalHeroCard: some View {
        HStack(spacing: 16) {
            // Botanical Avatar Emblem
            ZStack {
                Circle()
                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 2.5)
                    .frame(width: 72, height: 72)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.surfaceSecondary, AppColors.softGreen.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                if isGuest {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)
                } else {
                    Text(initials(from: displayName))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.forestGreen)
                }

                Circle()
                    .fill(isGuest ? AppColors.carbsOrange : AppColors.primary)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 22, y: 22)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Status Pill
                    HStack(spacing: 4) {
                        Image(systemName: isGuest ? "person.crop.circle" : "checkmark.seal.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(isGuest ? "Chế độ Khách" : "Đã xác thực")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(isGuest ? AppColors.forestGreen : AppColors.primaryDark)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())

                    // Goal Pill
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11))
                        Text(localizedGoal)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .overlay(Capsule().stroke(AppColors.border, lineWidth: 1))
                    .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(16)
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

    private var nutritionTargetsCard: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.surfaceSecondary)
                            .frame(width: 34, height: 34)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 17))
                            .foregroundColor(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mục tiêu dinh dưỡng")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Ngân sách calo & đa lượng mỗi ngày")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Button {
                    showingNutritionGoalsSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Thiết lập")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                }
            }

            // Calorie Highlight Strip
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("NĂNG LƯỢNG MỤC TIÊU")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(0.5)

                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("\(Int(viewModel.profile.dailyCalorieTarget))")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.primary)
                            .monospacedDigit()
                            .lineLimit(1)
                        Text("kcal / ngày")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)

                Spacer()

                // 3 mini macro pills
                HStack(spacing: 6) {
                    MacroMiniPill(label: "Đạm", val: "\(Int(viewModel.profile.dailyProteinTargetGrams))g", color: AppColors.proteinBlue)
                    MacroMiniPill(label: "Carb", val: "\(Int(viewModel.profile.dailyCarbTargetGrams))g", color: AppColors.carbsOrange)
                    MacroMiniPill(label: "Béo", val: "\(Int(viewModel.profile.dailyFatTargetGrams))g", color: AppColors.fatCoral)
                }
            }
            .padding(12)
            .background(AppColors.canvasBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .padding(16)
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

    private var quickMetricsSection: some View {
        HStack(spacing: 12) {
            // Metric 1: Biometrics
            Button {
                showingPersonalInfoSheet = true
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.surfaceSecondary)
                            .frame(width: 40, height: 40)
                        Image(systemName: "figure.walk")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Thể trạng")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text("Cân nặng & BMI")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.border, lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())

            // Metric 2: Water Target
            Button {
                showingPreferencesSheet = true
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "E8F2FA"))
                            .frame(width: 40, height: 40)
                        Image(systemName: "drop.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.proteinBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nước uống")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text("2.000 ml / ngày")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.border, lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var accountAndDataCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TÀI KHOẢN & DỮ LIỆU")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ProfileMenuRow(
                    icon: "lock.shield.fill",
                    title: "Tài khoản & Bảo mật",
                    subtitle: isGuest ? "Đang dùng Chế độ Khách (Lưu nội bộ)" : "Quản lý phiên đăng nhập và dữ liệu",
                    action: onOpenAccount
                )

                Divider()
                    .padding(.leading, 56)
                    .background(AppColors.divider)

                ProfileMenuRow(
                    icon: "fork.knife.circle.fill",
                    title: "Sở thích dinh dưỡng & Dị ứng",
                    subtitle: "Món ăn ưa thích, kiêng cữ cá nhân",
                    action: { showingPreferencesSheet = true }
                )
            }
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

    private var appAndAboutCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ỨNG DỤNG & THIẾT LẬP")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ProfileMenuRow(
                    icon: "gearshape.fill",
                    title: "Cài đặt ứng dụng",
                    subtitle: "Thông báo, camera AI, quyền riêng tư",
                    action: onOpenSettings
                )

                Divider()
                    .padding(.leading, 56)
                    .background(AppColors.divider)

                ProfileMenuRow(
                    icon: "leaf.circle.fill",
                    title: "Giới thiệu về NutriLens",
                    subtitle: "Công nghệ nhận diện AI món Việt on-device",
                    action: { showingAboutSheet = true }
                )
            }
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

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

private struct MacroMiniPill: View {
    let label: String
    let val: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
            Text(val)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
                .lineLimit(1)
            Capsule()
                .fill(color)
                .frame(width: 14, height: 3)
        }
        .frame(minWidth: 42)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(AppColors.border, lineWidth: 0.5))
    }
}

// MARK: - Supplementary Sheets

private struct PersonalInfoSheet: View {
    let profile: UserProfile
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 16) {
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
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
                .padding(.top, 16)
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
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 16) {
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("Thực đơn & Dị ứng thực phẩm")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Text("NutriLens ưu tiên nhận diện món ăn Việt Nam truyền thống và hiện đại. Bạn có thể thiết lập cảnh báo dị ứng hoặc chế độ ăn đặc biệt trong các bản cập nhật sắp tới.")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(3)
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.top, 16)
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
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
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
                    .padding(.top, 24)

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
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
