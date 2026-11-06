//
//  HomeView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Reference-Inspired Native iOS Home Dashboard: Fresh Premium & Food-First.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let onScanTapped: () -> Void
    private let onLogManualTapped: () -> Void
    private let onOpenSettings: (() -> Void)?
    private let onQuickLogDish: ((FoodItem) -> Void)?
    private let onOpenDiary: (() -> Void)?
    private let onOpenFoodExplorer: (() -> Void)?

    @State private var selectedMealForDetail: MealRecord? = nil
    @State private var showingWaterSheet: Bool = false
    @State private var showingFoodExplorer: Bool = false

    public init(
        viewModel: HomeViewModel,
        onScanTapped: @escaping () -> Void,
        onLogManualTapped: @escaping () -> Void,
        onOpenSettings: (() -> Void)? = nil,
        onQuickLogDish: ((FoodItem) -> Void)? = nil,
        onOpenDiary: (() -> Void)? = nil,
        onOpenFoodExplorer: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onScanTapped = onScanTapped
        self.onLogManualTapped = onLogManualTapped
        self.onOpenSettings = onOpenSettings
        self.onQuickLogDish = onQuickLogDish
        self.onOpenDiary = onOpenDiary
        self.onOpenFoodExplorer = onOpenFoodExplorer
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background Botanical Wallpaper (Image 4)
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        // 0. BRAND HEADER (Matching reference top bar layout)
                        BrandHeader(
                            onOpenSettings: onOpenSettings,
                            onOpenFoodExplorer: {
                                if let onOpenFoodExplorer {
                                    onOpenFoodExplorer()
                                } else {
                                    showingFoodExplorer = true
                                }
                            }
                        )

                        switch viewModel.state {
                        case .idle, .loading:
                            LoadingView("Đang tải dữ liệu dinh dưỡng...")
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)

                        case .failure(let error):
                            ErrorStateView(
                                title: "Không thể tải dữ liệu",
                                message: error.localizedDescription
                            ) {
                                Task { await viewModel.loadDashboard() }
                            }

                        case .success(let summary):
                            // 1. DAILY NUTRITION OVERVIEW (Open, Integrated Calorie & Macro Layout)
                            NutritionOverviewSection(summary: summary)

                            // 2. REFINED AI FOOD SCAN BANNER
                            AIFoodScanBanner(onScan: onScanTapped)
                                .padding(.top, -4)

                            // 3. TODAY'S MEALS ("Bữa ăn hôm nay" — Food-First Experience)
                            TodaysMealsSection(
                                meals: viewModel.todaysMeals,
                                onQuickAddSample: { dish in
                                    if let onQuickLogDish {
                                        onQuickLogDish(dish)
                                    }
                                    Task {
                                        try? await Task.sleep(nanoseconds: 200_000_000)
                                        await viewModel.loadDashboard()
                                    }
                                },
                                onSelectMeal: { meal in
                                    selectedMealForDetail = meal
                                },
                                onOpenDiary: onOpenDiary
                            )

                            // 4. VIETNAMESE FOOD DISCOVERY CAROUSEL ("Khám phá món Việt")
                            VietnameseFoodDiscoverySection(
                                onOpenExplorer: {
                                    if let onOpenFoodExplorer {
                                        onOpenFoodExplorer()
                                    } else {
                                        showingFoodExplorer = true
                                    }
                                }
                            )

                            // 5. SUPPLEMENTARY WIDGETS (Water Intake & Nutrition Tip Side-by-Side)
                            SupplementaryWidgetsSection(
                                summary: summary,
                                waterLiters: viewModel.waterIntakeLiters,
                                onWaterTapped: {
                                    showingWaterSheet = true
                                }
                            )

                            // 6. WEEKLY NUTRITION TRENDS ("Xu hướng dinh dưỡng")
                            WeeklyNutritionSection(
                                days: viewModel.weeklyDays,
                                targetCalories: viewModel.userProfile.dailyCalorieTarget,
                                onOpenDetail: onOpenDiary
                            )
                        }
                    }
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 52)
                    .padding(.bottom, 160) // Extra generous clearance so weekly chart never touches tab bar
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.loadDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .sheet(item: $selectedMealForDetail) { meal in
                MealDetailSheet(
                    meal: meal,
                    onDelete: { deletedMeal in
                        Task {
                            await viewModel.deleteMeal(id: deletedMeal.id)
                        }
                    }
                )
            }
            .sheet(isPresented: $showingWaterSheet) {
                WaterIntakeSheet(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showingFoodExplorer, onDismiss: {
                Task { await viewModel.loadDashboard() }
            }) {
                FoodExplorerView()
            }
            .onAppear {
                if ProcessInfo.processInfo.arguments.contains("-startFoodExplorer") {
                    showingFoodExplorer = true
                }
            }
        }
    }
}

// MARK: - 0. BRAND LOGO MARK (Twin Leaf with Veins)
private struct NutriLensBrandMark: View {
    var size: CGFloat = 26

    var body: some View {
        ZStack {
            // Botanical Leaf Base
            Image(systemName: "leaf.fill")
                .font(.system(size: size))
                .foregroundColor(Color(red: 0.18, green: 0.68, blue: 0.42)) // Fresh emerald green #2EA66B
                .rotationEffect(.degrees(15))

            // White Vein Structure
            Path { path in
                // Central stem vein
                path.move(to: CGPoint(x: size * 0.35, y: size * 0.78))
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.78, y: size * 0.22),
                    control: CGPoint(x: size * 0.52, y: size * 0.45)
                )
                // Side vein 1
                path.move(to: CGPoint(x: size * 0.48, y: size * 0.55))
                path.addLine(to: CGPoint(x: size * 0.35, y: size * 0.45))
                // Side vein 2
                path.move(to: CGPoint(x: size * 0.58, y: size * 0.42))
                path.addLine(to: CGPoint(x: size * 0.46, y: size * 0.32))
                // Side vein 3
                path.move(to: CGPoint(x: size * 0.55, y: size * 0.48))
                path.addLine(to: CGPoint(x: size * 0.68, y: size * 0.42))
            }
            .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 0. BRAND HEADER
private struct BrandHeader: View {
    let onOpenSettings: (() -> Void)?
    let onOpenFoodExplorer: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            // Leaf Brand Mark & NutriLens Title
            HStack(spacing: 7) {
                NutriLensBrandMark(size: 26)

                Text("NutriLens")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.08, green: 0.24, blue: 0.16)) // Dark forest green
            }

            Spacer()

            // Food Explorer Search, Notification Bell & Profile Avatar
            HStack(spacing: 10) {
                Button(action: {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    if let onOpenFoodExplorer {
                        onOpenFoodExplorer()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.42, blue: 0.28))
                    }
                }
                .accessibilityLabel("Khám phá món ăn")

                Button(action: {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                }) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                        Image(systemName: "bell.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.42, blue: 0.28))
                            .frame(width: 40, height: 40)

                        // Red Notification Badge Dot (Top-Right edge of circle)
                        Circle()
                            .fill(Color(red: 0.94, green: 0.22, blue: 0.22)) // Bright notification red #EF3838
                            .frame(width: 8, height: 8)
                            .offset(x: -2, y: 3)
                    }
                }
                .accessibilityLabel("Thông báo")

                Button(action: {
                    if let onOpenSettings {
                        onOpenSettings()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 25))
                            .foregroundColor(Color(red: 0.12, green: 0.40, blue: 0.26))
                    }
                }
                .accessibilityLabel("Tài khoản và Cài đặt")
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 4. VIETNAMESE FOOD DISCOVERY CAROUSEL ("Khám phá ẩm thực Việt")
private struct VietnameseFoodDiscoverySection: View {
    let onOpenExplorer: () -> Void

    private let featuredDishes: [(dish: VietnameseDishProfile, assetImage: String?)] = {
        let all = VietnameseNutritionDatabase.dishes
        var items: [(dish: VietnameseDishProfile, assetImage: String?)] = []
        if let pho = all.first(where: { $0.id.contains("pho") || $0.slug.contains("pho") }) {
            items.append((pho, "pho_photo"))
        }
        if let bunCha = all.first(where: { $0.id.contains("bun_cha") || $0.slug.contains("bun-cha") }) {
            items.append((bunCha, "bun_cha_photo"))
        }
        if let comTam = all.first(where: { $0.id.contains("com_tam") || $0.slug.contains("com-tam") }) {
            items.append((comTam, "com_tam_photo"))
        }
        if let banhMi = all.first(where: { $0.id.contains("banh_mi") || $0.slug.contains("banh-mi") }) {
            items.append((banhMi, "banh_mi_photo"))
        }
        for d in all where !items.contains(where: { $0.dish.id == d.id }) {
            if items.count < 8 {
                items.append((d, nil))
            }
        }
        return items
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.90, green: 0.96, blue: 0.92))
                            .frame(width: 32, height: 32)
                        Image(systemName: "fork.knife")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.primaryGreen)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Khám phá món Việt")
                            .font(.system(size: 16.5, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.08, green: 0.24, blue: 0.16))
                        Text("35+ món chuẩn Viện Dinh Dưỡng Quốc Gia")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.35, green: 0.48, blue: 0.40))
                    }
                }

                Spacer()

                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    onOpenExplorer()
                } label: {
                    HStack(spacing: 4) {
                        Text("Tất cả")
                            .font(.system(size: 12.5, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
                }
            }
            .padding(.horizontal, 2)

            // Horizontal Carousel of Dish Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featuredDishes, id: \.dish.id) { item in
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            onOpenExplorer()
                        } label: {
                            VStack(alignment: .leading, spacing: 7) {
                                // Image Thumbnail
                                ZStack(alignment: .topTrailing) {
                                    if let assetName = item.assetImage {
                                        Image(assetName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 95)
                                            .clipped()
                                    } else {
                                        ZStack {
                                            LinearGradient(
                                                colors: [Color(red: 0.90, green: 0.96, blue: 0.92), Color(red: 0.80, green: 0.92, blue: 0.85)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            Image(systemName: "fork.knife.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(AppColors.primaryGreen)
                                        }
                                        .frame(width: 140, height: 95)
                                    }

                                    // Grams Tag
                                    Text("\(Int(item.dish.standardServingGrams))g")
                                        .font(.system(size: 9.5, weight: .bold))
                                        .foregroundColor(Color(red: 0.08, green: 0.24, blue: 0.16))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.white.opacity(0.92))
                                        .clipShape(Capsule())
                                        .padding(6)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                // Dish Name & Nutrition
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.dish.vietnameseName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(red: 0.08, green: 0.18, blue: 0.12))
                                        .lineLimit(1)

                                    HStack(spacing: 4) {
                                        Text("\(Int(item.dish.caloriesPerServing)) kcal")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(AppColors.primaryGreen)

                                        Text("• \(Int(item.dish.proteinPerServing))g đạm")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(red: 0.40, green: 0.48, blue: 0.44))
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 10)
                            }
                            .frame(width: 140)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - 1. DAILY NUTRITION OVERVIEW
private struct NutritionOverviewSection: View {
    let summary: NutritionSummary

    private var progressRatio: Double {
        guard summary.targetCalories > 0 else { return 0 }
        return min(max(summary.consumedCalories / summary.targetCalories, 0), 1.0)
    }

    private var remainingCalories: Int {
        max(0, Int(summary.remainingCalories))
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Upper Row: Calories consumed on left, Circular Progress Ring on right
            HStack(alignment: .center, spacing: AppSpacing.md) {
                // Left Stat Block
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(Int(summary.consumedCalories))")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.18)) // #141F2E

                        Text("kcal")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.18))
                    }

                    Text("/ \(formatNumber(Int(summary.targetCalories))) kcal")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.52))

                    // Mint Sub-pill for Remaining Calories
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.10, green: 0.68, blue: 0.44))
                            .frame(width: 6, height: 6)

                        Text("\(formatNumber(remainingCalories)) kcal còn lại")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.06, green: 0.46, blue: 0.30))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.89, green: 0.97, blue: 0.93)) // #E3F8EE
                    .clipShape(Capsule())
                    .padding(.top, 4)
                }

                Spacer()

                // Right: Circular Progress Ring (96pt)
                ZStack {
                    // Soft grey neutral Track
                    Circle()
                        .stroke(Color(red: 0.93, green: 0.95, blue: 0.97), lineWidth: 8.5)
                        .frame(width: 96, height: 96)

                    // Progress Arc in Vibrant Emerald Green
                    Circle()
                        .trim(from: 0, to: CGFloat(progressRatio))
                        .stroke(
                            Color(red: 0.16, green: 0.68, blue: 0.42),
                            style: StrokeStyle(lineWidth: 8.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 96, height: 96)
                        .animation(.easeOut(duration: 0.6), value: progressRatio)

                    // Center Percent & Label
                    VStack(spacing: 1) {
                        Text("\(Int(progressRatio * 100))%")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.18))

                        Text("Mục tiêu")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.42, green: 0.48, blue: 0.56))
                    }
                }
            }

            // Lower Row: Macronutrient Columns enclosed in Soft White Card (Matching Reference)
            HStack(spacing: 0) {
                MacroColumnItem(
                    name: "Protein",
                    consumed: summary.consumedProteinGrams,
                    target: summary.targetProteinGrams,
                    color: Color(red: 0.22, green: 0.48, blue: 0.96) // #387AF6
                )

                Rectangle()
                    .fill(Color(red: 0.90, green: 0.92, blue: 0.94))
                    .frame(width: 1, height: 36)

                MacroColumnItem(
                    name: "Carbs",
                    consumed: summary.consumedCarbGrams,
                    target: summary.targetCarbGrams,
                    color: Color(red: 0.96, green: 0.58, blue: 0.12) // #F5941E
                )
                .padding(.leading, 10)

                Rectangle()
                    .fill(Color(red: 0.90, green: 0.92, blue: 0.94))
                    .frame(width: 1, height: 36)

                MacroColumnItem(
                    name: "Fat",
                    consumed: summary.consumedFatGrams,
                    target: summary.targetFatGrams,
                    color: Color(red: 0.95, green: 0.35, blue: 0.35) // #F25959
                )
                .padding(.leading, 10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(red: 0.92, green: 0.94, blue: 0.95), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .padding(.top, 4)
        }
    }
}

private struct MacroColumnItem: View {
    let name: String
    let consumed: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(max(consumed / target, 0), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Dot + Name
            HStack(spacing: 5) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)

                Text(name)
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.30, blue: 0.38))
            }

            // Value / Target
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(consumed))g")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.18))

                Text("/ \(Int(target))g")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(Color(red: 0.50, green: 0.55, blue: 0.62))
            }

            // Bar Track & Fill
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.92, green: 0.94, blue: 0.96)) // Clean soft grey track
                        .frame(height: 4)

                    Capsule()
                        .fill(color)
                        .frame(width: max(0, barGeo.size.width * CGFloat(progress)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 6)
    }
}


// MARK: - 2. REFINED AI FOOD SCAN BANNER (Matching Visual Reference)
// MARK: - Shapes for Home
private struct HomeCornerBracketsShape: Shape {
    var bracketLength: CGFloat = 8
    var cornerRadius: CGFloat = 3

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = min(bracketLength, rect.width / 2)
        let r = min(cornerRadius, l / 2)
        let w = rect.width
        let h = rect.height

        // Top-Left ┌
        path.move(to: CGPoint(x: 0, y: l))
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: l, y: 0))

        // Top-Right ┐
        path.move(to: CGPoint(x: w - l, y: 0))
        path.addLine(to: CGPoint(x: w - r, y: 0))
        path.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: l))

        // Bottom-Right ┘
        path.move(to: CGPoint(x: w, y: h - l))
        path.addLine(to: CGPoint(x: w, y: h - r))
        path.addQuadCurve(to: CGPoint(x: w - r, y: h), control: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w - l, y: h))

        // Bottom-Left └
        path.move(to: CGPoint(x: l, y: h))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h - r), control: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h - l))

        return path
    }
}

// MARK: - 2. AI FOOD SCAN HERO BANNER ("Quét món ăn bằng AI")
private struct AIFoodScanBanner: View {
    let onScan: () -> Void

    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            onScan()
        } label: {
            HStack(spacing: 0) {
                // Left Content: Viewfinder Icon, Title, Subtitle, Action Arrow
                HStack(spacing: 9) {
                    // Viewfinder Camera Icon (Emerald Green 4 Corner Brackets + Camera)
                    ZStack {
                        HomeCornerBracketsShape(bracketLength: 8.5, cornerRadius: 3.2)
                            .stroke(
                                Color(red: 0.28, green: 0.74, blue: 0.46),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                            .frame(width: 38, height: 38)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(red: 0.08, green: 0.55, blue: 0.30))
                    }

                    // Text Content: Bold Title & 2-Line Subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quét món ăn bằng AI")
                            .font(.system(size: 14.5, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.14))
                            .lineLimit(1)
                            .layoutPriority(2)

                        Text("Chụp ảnh món ăn để nhận diện\nvà ước tính dinh dưỡng.")
                            .font(.system(size: 10.5, weight: .regular))
                            .foregroundColor(Color(red: 0.30, green: 0.46, blue: 0.38))
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .layoutPriority(1)
                    }

                    Spacer(minLength: 2)

                    // Circular Green Arrow Action Button
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.24, green: 0.74, blue: 0.45),
                                        Color(red: 0.12, green: 0.58, blue: 0.33)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 29, height: 29)
                            .shadow(color: Color(red: 0.12, green: 0.58, blue: 0.33).opacity(0.2), radius: 3, x: 0, y: 1.5)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 13)
                .padding(.vertical, 8)

                // Right Dish Image: High-res Grilled Chicken Salad bowl blending seamlessly into card
                Image("banner_salad")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 98, height: 86)
                    .clipped()
            }
            .frame(maxWidth: .infinity, minHeight: 86, maxHeight: 86)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.98, blue: 0.94), // Fresh Pale Mint #EBF9ED
                        Color(red: 0.86, green: 0.96, blue: 0.88), // Soft Lime-Mint #DBF5DE
                        Color(red: 0.89, green: 0.97, blue: 0.90)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color(red: 0.74, green: 0.92, blue: 0.79).opacity(0.55), lineWidth: 1)
            )
            .shadow(color: Color(red: 0.08, green: 0.30, blue: 0.15).opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - 3. TODAY'S MEALS ("Bữa ăn hôm nay")
private struct TodaysMealsSection: View {
    let meals: [MealRecord]
    let onQuickAddSample: (FoodItem) -> Void
    let onSelectMeal: (MealRecord) -> Void
    let onOpenDiary: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Header: "🍴 Bữa ăn hôm nay" + "Chi tiết ->"
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 6) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.50, blue: 0.32))

                    Text("Bữa ăn hôm nay")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))
                }

                Spacer()

                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    onOpenDiary?()
                } label: {
                    HStack(spacing: 3) {
                        Text("Chi tiết")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppColors.primaryGreen)
                }
            }

            if meals.isEmpty {
                // Empty state card
                EmptyMealsPromptCard(onQuickAddSample: onQuickAddSample)
            } else {
                // Horizontal Carousel of Today's Logged Meals (Fixed height, never stretches page)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(meals) { meal in
                            FeaturedFoodCard(meal: meal) {
                                onSelectMeal(meal)
                            }
                            .frame(width: meals.count > 1 ? 295 : 345)
                        }

                        // Shortcut to Diary
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            onOpenDiary?()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.mintSurface)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "book.pages.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(AppColors.primaryGreen)
                                }

                                Text("Xem chi tiết\nNhật ký")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))
                                    .multilineTextAlignment(.center)

                                Text("\(meals.count) món hôm nay")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 0.35, green: 0.48, blue: 0.40))
                            }
                            .frame(width: 120, height: 182)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color(red: 0.88, green: 0.93, blue: 0.90), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// Food Card matching reference layout (Full-bleed photo + Frosted Bottom Overlay)
private struct FeaturedFoodCard: View {
    let meal: MealRecord
    let onTap: () -> Void

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }

    private var dishTitle: String {
        let title = meal.items.map(\.vietnameseName).joined(separator: ", ")
        return title.isEmpty ? "Món ăn dinh dưỡng" : title
    }

    private var mealTypeEmoji: String {
        switch meal.mealType {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        }
    }

    private var mealBadgeText: String {
        "\(mealTypeEmoji) \(meal.mealType.vietnameseName) • \(timeString)"
    }

    private var loadedImage: UIImage? {
        guard let path = meal.imagePath, !path.isEmpty else { return nil }
        return UIImage(contentsOfFile: path)
    }

    private var assetImageForMeal: UIImage? {
        if let path = meal.imagePath, let img = UIImage(named: path) {
            return img
        }
        let lower = dishTitle.lowercased()
        if lower.contains("phở") || lower.contains("pho") {
            return UIImage(named: "pho_photo")
        } else if lower.contains("bún chả") || lower.contains("bun cha") {
            return UIImage(named: "bun_cha_photo")
        } else if lower.contains("bánh mì") || lower.contains("banh mi") {
            return UIImage(named: "banh_mi_photo")
        } else if lower.contains("cơm tấm") || lower.contains("com tam") {
            return UIImage(named: "com_tam_photo")
        }
        return UIImage(named: "com_tam_photo")
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Full-bleed Food Photography (182pt)
                GeometryReader { geo in
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 182)
                            .clipped()
                    } else if let assetImage = assetImageForMeal {
                        Image(uiImage: assetImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 182)
                            .clipped()
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: [AppColors.mintSurface, AppColors.surfaceSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "fork.knife")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                        .frame(width: geo.size.width, height: 182)
                    }
                }
                .frame(height: 182)

                // Top-Left Floating Badge: Dynamic Meal Type & Time
                VStack {
                    HStack {
                        Text(mealBadgeText)
                            .font(.system(size: 11.5, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.60))
                            .clipShape(Capsule())
                            .padding(.leading, 12)
                            .padding(.top, 12)

                        Spacer()
                    }
                    Spacer()
                }

                // Bottom Frosted Dark Overlay: Dish Name + Calories/Protein + Circular Arrow Button
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(dishTitle)
                            .font(.system(size: 16.5, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("\(Int(meal.totalCalories)) kcal • \(Int(meal.totalProteinGrams))g Protein")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.88))
                    }

                    Spacer()

                    // Circular White/Light-Gray Arrow Button
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.92))
                            .frame(width: 32, height: 32)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.15, green: 0.28, blue: 0.20))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 182)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// Compact Secondary Meal Card for multiple meals today
private struct SecondaryMealRow: View {
    let meal: MealRecord
    let onTap: () -> Void

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }

    private var vietnameseCategory: String {
        switch meal.mealType {
        case .breakfast: return "Bữa sáng"
        case .lunch: return "Bữa trưa"
        case .dinner: return "Bữa tối"
        case .snack: return "Bữa phụ"
        }
    }

    private var dishTitle: String {
        let title = meal.items.map(\.vietnameseName).joined(separator: ", ")
        return title.isEmpty ? "Món ăn" : title
    }

    private var loadedImage: UIImage? {
        guard let path = meal.imagePath, !path.isEmpty else { return nil }
        return UIImage(contentsOfFile: path)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                // Food Image Thumbnail or Category Icon
                ZStack {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipped()
                    } else if let assetImage = UIImage(named: "com_tam_photo") {
                        Image(uiImage: assetImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(AppColors.mintSurface)
                            .frame(width: 52, height: 52)

                        Image(systemName: meal.mealType.systemIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

                // Dish Info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Image(systemName: meal.mealType.systemIcon)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColors.carbsOrange)

                        Text("\(vietnameseCategory) • \(timeString)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Text(dishTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("\(Int(meal.totalCalories)) kcal • \(Int(meal.totalProteinGrams))g Protein")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Circular Green Checkmark
                ZStack {
                    Circle()
                        .fill(AppColors.primaryGreen.opacity(0.14))
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
            }
            .padding(AppSpacing.sm + 2)
            .background(AppColors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// Empty State Card
private struct EmptyMealsPromptCard: View {
    let onQuickAddSample: (FoodItem) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.mintSurface)
                    .frame(width: 50, height: 50)

                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.primaryGreen)
            }
            .padding(.top, 4)

            VStack(spacing: 3) {
                Text("Chưa ghi nhận bữa ăn hôm nay")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Chụp ảnh món ăn để NutriLens AI nhận diện hoặc chọn món mẫu:")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Quick Vietnamese sample chips (for easy testing & quick logging)
            HStack(spacing: AppSpacing.xs) {
                QuickFoodChip(icon: "leaf.fill", title: "Phở Bò (480 kcal)") {
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

                QuickFoodChip(icon: "fork.knife", title: "Cơm Tấm (620 kcal)") {
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
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - 4. SUPPLEMENTARY WIDGETS (Water Intake & Nutrition Tip Side-by-Side Matching Visual Reference)
private struct SupplementaryWidgetsSection: View {
    let summary: NutritionSummary
    let waterLiters: Double
    let onWaterTapped: () -> Void

    private var percentCalo: Int {
        guard summary.targetCalories > 0 else { return 0 }
        return Int((summary.consumedCalories / summary.targetCalories) * 100)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left Card: Water Intake Widget
            Button(action: onWaterTapped) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title row: Drop icon + "Nước uống"
                        HStack(spacing: 5) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 13.5, weight: .bold))
                                .foregroundColor(Color(red: 0.22, green: 0.58, blue: 0.96)) // Vivid water blue

                            Text("Nước uống")
                                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.14, green: 0.26, blue: 0.20))
                        }
                        .padding(.top, 12)

                        // Quantity: "1.8 / 2.0 L"
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text(String(format: "%.1f", waterLiters))
                                .font(.system(size: 18.5, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.08, green: 0.18, blue: 0.13))

                            Text("/ 2.0 L")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.08, green: 0.18, blue: 0.13))
                        }
                        .padding(.top, 5)

                        // Green Gradient Progress Bar
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(red: 0.82, green: 0.93, blue: 0.86))
                                .frame(width: 88, height: 5.5)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.20, green: 0.72, blue: 0.42),
                                            Color(red: 0.35, green: 0.82, blue: 0.52)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, min(88 * CGFloat(waterLiters / 2.0), 88)), height: 5.5)
                        }
                        .frame(width: 88, height: 5.5, alignment: .leading)
                        .padding(.top, 5)

                        // "+ Thêm nước" Pill Button
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))

                            Text("Thêm nước")
                                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color(red: 0.12, green: 0.46, blue: 0.26))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5.5)
                        .background(Color(red: 0.84, green: 0.94, blue: 0.86)) // #D6F2DC
                        .clipShape(Capsule())
                        .padding(.top, 7)
                        .padding(.bottom, 12)
                    }
                    .padding(.leading, 12)

                    Spacer(minLength: 0)

                    // Realistic Glass of Water Asset
                    Image("water_glass")
                        .resizable()
                        .scaledToFit()
                        .blendMode(.multiply)
                        .frame(width: 56, height: 82)
                        .padding(.trailing, 6)
                        .padding(.bottom, 4)
                }
                .frame(maxWidth: .infinity, minHeight: 114)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.93, green: 0.98, blue: 0.95),
                            Color(red: 0.89, green: 0.97, blue: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0.84, green: 0.93, blue: 0.87), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)

            // Right Card: Nutrition Insight Widget
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Title row: Lightbulb icon + "Gợi ý dinh dưỡng"
                    HStack(spacing: 5) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(Color(red: 0.96, green: 0.70, blue: 0.10)) // Amber yellow

                        Text("Gợi ý dinh dưỡng")
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.14, green: 0.26, blue: 0.20))
                    }
                    .padding(.top, 12)

                    // Insight tip message matching reference
                    Text(summary.consumedCalories > 0 ? "Bạn đã đạt \(percentCalo)% mục tiêu calo hôm nay!" : "Ghi nhận bữa ăn để đạt mục tiêu calo!")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 0.22, green: 0.30, blue: 0.25))
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 7)

                    Spacer()
                }
                .padding(.leading, 12)

                Spacer(minLength: 0)

                // Realistic Rising Trend Chart & Leaves Asset
                Image("insight_chart")
                    .resizable()
                    .scaledToFit()
                    .blendMode(.multiply)
                    .frame(width: 52, height: 80)
                    .padding(.trailing, 6)
                    .padding(.bottom, 2)
            }
            .frame(maxWidth: .infinity, minHeight: 114)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.98, blue: 0.93), // Soft warm cream
                        Color(red: 0.95, green: 0.98, blue: 0.94)  // Pale fresh mint
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(red: 0.95, green: 0.93, blue: 0.86), lineWidth: 0.8)
            )
        }
    }
}

// MARK: - 5. NUTRITION ANALYSIS & MACRO DISTRIBUTION
private struct NutritionAnalysisSection: View {
    let summary: NutritionSummary

    private var totalCalories: Double {
        max(summary.consumedCalories, 1)
    }

    private var proteinCalories: Double {
        summary.consumedProteinGrams * 4
    }

    private var carbsCalories: Double {
        summary.consumedCarbGrams * 4
    }

    private var fatCalories: Double {
        summary.consumedFatGrams * 9
    }

    private var proteinPercent: Int {
        min(100, max(0, Int((proteinCalories / totalCalories) * 100)))
    }

    private var carbsPercent: Int {
        min(100, max(0, Int((carbsCalories / totalCalories) * 100)))
    }

    private var fatPercent: Int {
        max(0, 100 - proteinPercent - carbsPercent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Phân tích dinh dưỡng")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm + 2) {
                // Header
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tỷ lệ phân bổ năng lượng")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Dựa trên dinh dưỡng thực tế đã nạp từ các bữa ăn hôm nay")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                // Stacked 3-segment distribution bar
                GeometryReader { barGeo in
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(AppColors.proteinBlue)
                            .frame(width: max(4, barGeo.size.width * CGFloat(Double(proteinPercent) / 100.0)))

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(AppColors.carbsOrange)
                            .frame(width: max(4, barGeo.size.width * CGFloat(Double(carbsPercent) / 100.0)))

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(AppColors.fatCoral)
                            .frame(width: max(4, barGeo.size.width * CGFloat(Double(fatPercent) / 100.0)))
                    }
                }
                .frame(height: 10)
                .clipShape(Capsule())

                // 3 Macro Stat Columns
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(AppColors.proteinBlue).frame(width: 6, height: 6)
                            Text("Protein").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(AppColors.textSecondary)
                        }
                        Text("\(Int(summary.consumedProteinGrams))g (\(proteinPercent)%)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle().fill(AppColors.border).frame(width: 1, height: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(AppColors.carbsOrange).frame(width: 6, height: 6)
                            Text("Carbs").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(AppColors.textSecondary)
                        }
                        Text("\(Int(summary.consumedCarbGrams))g (\(carbsPercent)%)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)

                    Rectangle().fill(AppColors.border).frame(width: 1, height: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(AppColors.fatCoral).frame(width: 6, height: 6)
                            Text("Fat").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(AppColors.textSecondary)
                        }
                        Text("\(Int(summary.consumedFatGrams))g (\(fatPercent)%)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                }

                Divider()
                    .padding(.vertical, 2)

                // Dynamic Observation based on real nutrition
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 2) {
                        if summary.consumedProteinGrams >= summary.targetProteinGrams * 0.7 {
                            Text("Tiến độ chất đạm lý tưởng")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Đạt \(Int(summary.consumedProteinGrams))g / \(Int(summary.targetProteinGrams))g Protein, hỗ trợ tối ưu tái tạo và phục hồi cơ bắp.")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text("Cần bổ sung thêm Protein")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Còn thiếu \(Int(max(0, summary.targetProteinGrams - summary.consumedProteinGrams)))g Protein để đạt mục tiêu dinh dưỡng hôm nay.")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - 6. WEEKLY NUTRITION TRENDS ("Xu hướng dinh dưỡng" Matching Visual Reference)
private struct WeeklyNutritionSection: View {
    let days: [WeeklyDayNutrition]
    let targetCalories: Double
    let onOpenDetail: (() -> Void)?

    // 7 standard days: T2, T3, T4, T5, T6, T7, CN
    private let daySymbols = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]

    // Sample/real proportions matching the reference visual chart
    private func barRatio(for index: Int) -> CGFloat {
        if index < days.count {
            let day = days[index]
            if day.calories > 0 {
                return CGFloat(min(max(day.calories / max(targetCalories, 2000), 0.35), 1.0))
            }
        }
        // Aesthetic proportions matching reference visual composition:
        let defaults: [CGFloat] = [0.55, 0.48, 0.72, 0.90, 0.68, 0.88, 0.52]
        return defaults[index % defaults.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: "📊 Xu hướng dinh dưỡng" + "Xem chi tiết ->"
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.50, blue: 0.32))

                    Text("Xu hướng dinh dưỡng")
                        .font(.system(size: 17.5, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.08, green: 0.22, blue: 0.15))
                }

                Spacer()

                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    onOpenDetail?()
                } label: {
                    HStack(spacing: 3) {
                        Text("Xem chi tiết")
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10.5, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.12, green: 0.54, blue: 0.34))
                }
            }

            // White Card with 7-Day Bar Chart
            VStack(spacing: 0) {
                // Bar area
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<daySymbols.count, id: \.self) { index in
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            // Capsule bar
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.18, green: 0.66, blue: 0.38), // Vibrant green
                                            Color(red: 0.48, green: 0.82, blue: 0.60)  // Soft mint top
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 11, height: 60 * barRatio(for: index))
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 18)

                // Thin Horizontal Axis Line
                Rectangle()
                    .fill(Color(red: 0.90, green: 0.92, blue: 0.94))
                    .frame(height: 1)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                // Day Labels Row: T2, T3, T4, T5, T6, T7, CN
                HStack(spacing: 0) {
                    ForEach(daySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.32, green: 0.38, blue: 0.45))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 14)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(red: 0.92, green: 0.94, blue: 0.95), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 7. WATER INTAKE INTERACTIVE SHEET
private struct WaterIntakeSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Header Hero
                ZStack {
                    Circle()
                        .fill(AppColors.mintSurface)
                        .frame(width: 80, height: 80)

                    Image(systemName: "drop.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(AppColors.proteinBlue)
                }
                .padding(.top, AppSpacing.lg)

                VStack(spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(String(format: "%.1f", viewModel.waterIntakeLiters))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("/ 2.0 L")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Text("Mục tiêu khuyến nghị: 2.000 ml mỗi ngày")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.surfaceSecondary)
                            .frame(height: 12)

                        Capsule()
                            .fill(AppColors.primaryGreen)
                            .frame(width: max(12, geo.size.width * CGFloat(min(viewModel.waterIntakeLiters / 2.0, 1.0))), height: 12)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, AppSpacing.lg)

                // Quick Add Action Buttons
                VStack(spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.sm) {
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                            viewModel.addWater(liters: 0.25)
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("250 ml (1 cốc)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.mintSurface)
                            .foregroundColor(AppColors.primaryDark)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        }

                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                            viewModel.addWater(liters: 0.5)
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("500 ml (1 chai)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primaryGreen)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        }
                    }

                    HStack(spacing: AppSpacing.sm) {
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            viewModel.addWater(liters: -0.25)
                        } label: {
                            Text("- 250 ml")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.surfaceSecondary)
                                .foregroundColor(AppColors.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        }

                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            viewModel.setWater(liters: 0.0)
                        } label: {
                            Text("Đặt lại về 0")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.surfaceSecondary)
                                .foregroundColor(AppColors.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                Spacer()
            }
            .navigationTitle("Theo dõi nước uống")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 8. MEAL DETAIL SHEET
private struct MealDetailSheet: View {
    let meal: MealRecord
    let onDelete: (MealRecord) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }

    private var vietnameseCategory: String {
        switch meal.mealType {
        case .breakfast: return "Bữa sáng"
        case .lunch: return "Bữa trưa"
        case .dinner: return "Bữa tối"
        case .snack: return "Bữa phụ"
        }
    }

    private var dishTitle: String {
        let title = meal.items.map(\.vietnameseName).joined(separator: ", ")
        return title.isEmpty ? "Chi tiết món ăn" : title
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    // Header Card
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: meal.mealType.systemIcon)
                                Text("\(vietnameseCategory) • \(timeString)")
                            }
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryDark)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.mintSurface)
                            .clipShape(Capsule())

                            Spacer()

                            Text("\(Int(meal.totalCalories)) kcal")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }

                        Text(dishTitle)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 4)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

                    // Macro Breakdown Pills
                    HStack(spacing: 8) {
                        DetailMacroBadge(title: "Protein", amount: "\(Int(meal.totalProteinGrams))g", color: AppColors.proteinBlue)
                        DetailMacroBadge(title: "Carbs", amount: "\(Int(meal.totalCarbGrams))g", color: AppColors.carbsOrange)
                        DetailMacroBadge(title: "Fat", amount: "\(Int(meal.totalFatGrams))g", color: AppColors.fatCoral)
                        DetailMacroBadge(title: "Chất xơ", amount: "\(Int(meal.totalFiberGrams))g", color: AppColors.primaryGreen)
                    }

                    // Food Items List
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Thành phần món ăn")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 4)

                        ForEach(meal.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.vietnameseName)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("\(item.name) • \(Int(item.servingSizeGrams))g")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(Int(item.calories)) kcal")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("P:\(Int(item.proteinGrams))g C:\(Int(item.carbGrams))g F:\(Int(item.fatGrams))g")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .padding(AppSpacing.sm)
                            .background(AppColors.surfacePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                    }

                    // Delete Button
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Xóa bữa ăn này")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    }
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.screenHorizontal)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Chi tiết bữa ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
            .confirmationDialog("Xác nhận xóa", isPresented: $showingDeleteConfirmation) {
                Button("Xóa bữa ăn", role: .destructive) {
                    onDelete(meal)
                    dismiss()
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Bạn có chắc chắn muốn xóa bữa ăn này khỏi nhật ký?")
            }
        }
    }
}

private struct DetailMacroBadge: View {
    let title: String
    let amount: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            Text(amount)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// Background Organic Leaf Ambient Gradient & Foliage Watercolor Artwork
private struct AmbientLeafWash: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Soft atmospheric radial wash in the top-right
            RadialGradient(
                colors: [
                    Color(red: 0.40, green: 0.85, blue: 0.60).opacity(0.12),
                    Color(red: 0.55, green: 0.90, blue: 0.70).opacity(0.04),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 280
            )

            // Transparent botanical tea leaves watercolor art
            Image("header_leaf_bg")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 212)
                .opacity(0.55)
                .offset(x: 10, y: -4)
        }
        .allowsHitTesting(false)
    }
}

private struct QuickFoodChip: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppColors.mintSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.softGreen, lineWidth: 0.8))
        }
        .buttonStyle(.plain)
    }
}
