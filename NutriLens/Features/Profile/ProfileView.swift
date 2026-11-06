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
    private let onOpenLogin: (() -> Void)?
    private let onOpenRegister: (() -> Void)?

    @State private var showingNutritionGoalsSheet: Bool = false
    @State private var showingPersonalInfoSheet: Bool = false
    @State private var showingPreferencesSheet: Bool = false
    @State private var showingAboutSheet: Bool = false

    public init(
        viewModel: ProfileViewModel,
        onOpenSettings: @escaping () -> Void,
        onOpenAccount: @escaping () -> Void = {},
        onOpenLogin: (() -> Void)? = nil,
        onOpenRegister: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenSettings = onOpenSettings
        self.onOpenAccount = onOpenAccount
        self.onOpenLogin = onOpenLogin
        self.onOpenRegister = onOpenRegister
    }

    private var isAuthenticated: Bool {
        viewModel.currentSession.isAuthenticated
    }

    private var isGuest: Bool {
        viewModel.currentSession.isGuest || !isAuthenticated
    }

    private var displayName: String {
        if let name = viewModel.currentSession.user?.displayName, !name.isEmpty {
            return name
        }
        if isAuthenticated {
            return viewModel.profile.name
        }
        return "Khách NutriLens"
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
                            // MARK: - 1. Identity Hero Card (Adaptive to Auth State)
                            if !isAuthenticated {
                                unauthenticatedHeroCard
                            } else {
                                personalHeroCard
                            }

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
            .fullScreenCover(isPresented: $showingNutritionGoalsSheet) {
                NutritionGoalsView(viewModel: viewModel) {
                    showingNutritionGoalsSheet = false
                }
            }
            .fullScreenCover(isPresented: $showingPersonalInfoSheet) {
                PersonalInfoView(profile: viewModel.profile) {
                    showingPersonalInfoSheet = false
                }
            }
            .fullScreenCover(isPresented: $showingPreferencesSheet) {
                PreferencesView {
                    showingPreferencesSheet = false
                }
            }
            .fullScreenCover(isPresented: $showingAboutSheet) {
                AboutView {
                    showingAboutSheet = false
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadProfile()
                }
            }
            .task {
                await viewModel.loadProfile()
                if ProcessInfo.processInfo.arguments.contains("-startNutritionGoals") {
                    showingNutritionGoalsSheet = true
                } else if ProcessInfo.processInfo.arguments.contains("-startPersonalInfo") {
                    showingPersonalInfoSheet = true
                } else if ProcessInfo.processInfo.arguments.contains("-startPreferences") {
                    showingPreferencesSheet = true
                } else if ProcessInfo.processInfo.arguments.contains("-startAbout") {
                    showingAboutSheet = true
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

    private var unauthenticatedHeroCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Botanical Avatar Emblem with Plus
                ZStack {
                    Circle()
                        .stroke(AppColors.primary.opacity(0.25), lineWidth: 2.5)
                        .frame(width: 66, height: 66)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.surfaceSecondary, AppColors.softGreen.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)

                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)

                    Circle()
                        .fill(AppColors.carbsOrange)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 20, y: 20)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Bạn chưa đăng nhập")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Đăng nhập để đồng bộ dinh dưỡng món Việt & quản lý tài khoản")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: 5) {
                        Circle()
                            .fill(AppColors.carbsOrange)
                            .frame(width: 6, height: 6)
                        Text("Chế độ Khách (Offline)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.forestGreen)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                    .padding(.top, 1)
                }

                Spacer()
            }

            // Dual CTA Buttons: Đăng nhập & Đăng ký
            HStack(spacing: 10) {
                Button {
                    if let onOpenLogin {
                        onOpenLogin()
                    } else {
                        onOpenAccount()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("Đăng nhập")
                            .font(AppTypography.bodyBold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: AppColors.primary.opacity(0.2), radius: 5, y: 2)
                }

                Button {
                    if let onOpenRegister {
                        onOpenRegister()
                    } else {
                        onOpenAccount()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("Đăng ký")
                            .font(AppTypography.bodyBold)
                    }
                    .foregroundColor(AppColors.forestGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.primary.opacity(0.35), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                }
            }

            // Trust note
            HStack(spacing: 6) {
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.primary)
                Text("Dữ liệu calo & món ăn vẫn được lưu an toàn trong SwiftData trên máy")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
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

// MARK: - Supplementary Full-Screen Pages

private struct PersonalInfoView: View {
    let profile: UserProfile
    let onDismiss: () -> Void

    private func localizedGoal(_ goal: DietaryGoal) -> String {
        switch goal {
        case .maintainWeight: return "Duy trì cân nặng"
        case .loseWeight: return "Giảm cân an toàn"
        case .gainMuscle: return "Tăng cơ săn chắc"
        case .balancedNutrition: return "Ăn uống lành mạnh"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Bar (Safe below Dynamic Island)
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Thông tin cá nhân")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Chỉ số thể trạng & hồ sơ sức khỏe")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Xong")
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
                    VStack(spacing: 16) {
                        // 1. Hero Identity Card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                                Circle()
                                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 2)
                                    .frame(width: 64, height: 64)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)

                                HStack(spacing: 6) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(AppColors.primary)
                                            .frame(width: 6, height: 6)
                                        Text("Thành viên NutriLens")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(AppColors.primaryDark)
                                    }
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(AppColors.surfaceSecondary)
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
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 2. Biometrics Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppColors.surfaceSecondary)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                }
                                Text("Chỉ số thể trạng cơ bản")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                MetricBox(title: "Chiều cao", val: "170 cm")
                                MetricBox(title: "Cân nặng", val: "65 kg")
                                MetricBox(title: "Chỉ số BMI", val: "22.5", sub: "Bình thường", color: AppColors.primary)
                            }

                            Divider()

                            HStack {
                                Text("Khoảng cân nặng khuyến nghị")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("58 – 72 kg")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 3. Nutrition Target Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppColors.surfaceSecondary)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "target")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.primary)
                                }
                                Text("Kế hoạch dinh dưỡng")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }

                            VStack(spacing: 10) {
                                InfoRow(label: "Mục tiêu thể trạng", value: localizedGoal(profile.goal), isAccent: true)
                                Divider()
                                InfoRow(label: "Ngân sách calo mỗi ngày", value: "\(Int(profile.dailyCalorieTarget)) kcal / ngày")
                                Divider()
                                InfoRow(label: "Mục tiêu nước uống", value: "2.000 ml / ngày")
                                Divider()
                                InfoRow(label: "Phân bổ đa lượng", value: "Đạm \(Int(profile.dailyProteinTargetGrams))g • Carb \(Int(profile.dailyCarbTargetGrams))g • Béo \(Int(profile.dailyFatTargetGrams))g")
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 4. Privacy & Security Callout
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.surfaceSecondary)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Lưu trữ bảo mật trên thiết bị")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Toàn bộ thông tin thể trạng và lịch sử calo được lưu trữ cục bộ trong SwiftData trên iPhone, không chia sẻ hay tải lên bất kỳ máy chủ nào.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

private struct PreferencesView: View {
    let onDismiss: () -> Void

    @State private var selectedStyle: String = "vietnamese"
    @State private var selectedAllergens: Set<String> = []

    private let styles: [(id: String, name: String, desc: String, icon: String)] = [
        ("vietnamese", "Món Việt 3 miền (Mặc định)", "Ưu tiên ẩm thực truyền thống & đặc sản địa phương", "fork.knife"),
        ("vegetarian", "Ăn chay / Thuần chay", "Tự động gợi ý các món chay dinh dưỡng", "leaf.fill"),
        ("lowcarb", "Keto / Low-Carb", "Hạn chế tinh bột, tập trung đạm & chất béo tốt", "bolt.fill"),
        ("eatclean", "Eat Clean / Thanh đạm", "Ưu tiên thực phẩm nguyên bản, ít gia vị dầu mỡ", "sparkles")
    ]

    private let allergens: [(id: String, name: String, icon: String)] = [
        ("seafood", "Hải sản (Tôm, Cua, Mực)", "fish.fill"),
        ("peanut", "Đậu phộng / Lạc", "circle.grid.2x1.fill"),
        ("egg", "Trứng gia cầm", "oval.fill"),
        ("dairy", "Sữa & Lactose", "cup.and.saucer.fill"),
        ("gluten", "Gluten / Bột mì", "allergens"),
        ("chili", "Ớt / Cay nồng", "flame.fill")
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Sở thích dinh dưỡng")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Khẩu vị & Cảnh báo dị ứng")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Xong")
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
                    VStack(spacing: 16) {
                        // 1. Dietary Style Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trường phái ẩm thực")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)

                            VStack(spacing: 8) {
                                ForEach(styles, id: \.id) { item in
                                    Button {
                                        selectedStyle = item.id
                                    } label: {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .stroke(selectedStyle == item.id ? AppColors.primary : AppColors.border, lineWidth: 2)
                                                    .frame(width: 20, height: 20)
                                                if selectedStyle == item.id {
                                                    Circle()
                                                        .fill(AppColors.primary)
                                                        .frame(width: 10, height: 10)
                                                }
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name)
                                                    .font(AppTypography.bodyBold)
                                                    .foregroundColor(AppColors.textPrimary)
                                                Text(item.desc)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }

                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(selectedStyle == item.id ? AppColors.surfaceSecondary : Color.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(selectedStyle == item.id ? AppColors.primary : AppColors.border, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 2. Allergen Warnings Card
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cảnh báo dị ứng thực phẩm")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("NutriLens sẽ hiển thị cảnh báo khi nhận diện món ăn có chứa các thành phần:")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(allergens, id: \.id) { allergen in
                                    let isSelected = selectedAllergens.contains(allergen.id)
                                    Button {
                                        if isSelected {
                                            selectedAllergens.remove(allergen.id)
                                        } else {
                                            selectedAllergens.insert(allergen.id)
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 15))
                                                .foregroundColor(isSelected ? AppColors.primary : AppColors.textTertiary)
                                            Text(allergen.name)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(isSelected ? AppColors.primaryDark : AppColors.textPrimary)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .background(isSelected ? AppColors.surfaceSecondary : Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 3. AI Recognition Optimization Card
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.surfaceSecondary)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Tối ưu hóa ẩm thực Việt")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Hệ thống AI on-device tự động ưu tiên nhận diện 5.000+ món ăn truyền thống 3 miền, tính toán calo chuẩn xác theo nguyên liệu và khẩu phần thực tế.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

private struct AboutView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Giới thiệu")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Về NutriLens AI 1.0")
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
                    VStack(spacing: 16) {
                        // 1. Hero Brand Emblem
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 3)
                                Circle()
                                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 2)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .rotationEffect(.degrees(12))
                            }

                            VStack(spacing: 4) {
                                Text("NutriLens")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)

                                Text("AI Dinh Dưỡng Món Việt • On-Device")
                                    .font(AppTypography.subheadlineBold)
                                    .foregroundColor(AppColors.primaryDark)

                                Text("Phiên bản 1.0.0 (Build 2026.11)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(AppColors.surfaceSecondary)
                                    .clipShape(Capsule())
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.top, 6)

                        // 2. Mission Statement Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sứ mệnh NutriLens")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)

                            Text("NutriLens kết hợp công nghệ Trí tuệ Nhân tạo thị giác máy tính on-device (Apple Vision / Core ML) và cơ sở dữ liệu ẩm thực Việt Nam độc quyền nhằm giúp người dùng theo dõi calo, cân bằng dưỡng chất và xây dựng lối sống lành mạnh bền vững mà không cần gửi ảnh lên đám mây.")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 3. Technology Pillars Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Trụ cột công nghệ cốt lõi")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)

                            VStack(spacing: 12) {
                                PillarRow(icon: "bolt.fill", title: "AI On-Device Siêu Tốc", desc: "Nhận diện tức thì dưới 0.3s trên chip Apple Neural Engine")
                                Divider()
                                PillarRow(icon: "fork.knife", title: "5.000+ Món Việt", desc: "Thực đơn đa dạng 3 miền từ phở, bún đến cơm tấm và món kho")
                                Divider()
                                PillarRow(icon: "lock.shield.fill", title: "Quyền Riêng Tư 100%", desc: "Ảnh chụp và nhật ký lưu an toàn trong SwiftData nội bộ của máy")
                                Divider()
                                PillarRow(icon: "chart.pie.fill", title: "Đa Lượng Khoa Học", desc: "Tự động phân bổ tỷ lệ Đạm - Carb - Béo theo khuyến nghị chuẩn")
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 4. Team & Tech Info Card
                        VStack(spacing: 6) {
                            Text("Phát triển bởi Đội ngũ NutriLens")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("SwiftData • SwiftUI • Core ML • Clean Architecture")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                            Text("© 2026 NutriLens. Mọi quyền được bảo lưu.")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - Helper Subviews

private struct MetricBox: View {
    let title: String
    let val: String
    var sub: String? = nil
    var color: Color = AppColors.textPrimary

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            Text(val)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            if let sub {
                Text(sub)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppColors.primaryDark)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(AppColors.surfaceSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var isAccent: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isAccent ? AppColors.primary : AppColors.textPrimary)
        }
    }
}

private struct PillarRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
    }
}
