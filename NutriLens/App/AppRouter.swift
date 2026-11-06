//
//  AppRouter.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case history = 1
    case scan = 2
    case stats = 3
    case profile = 4

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .home: return "Trang chủ"
        case .history: return "Nhật ký"
        case .scan: return "Quét"
        case .stats: return "Thống kê"
        case .profile: return "Cá nhân"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "book.pages"
        case .scan: return "camera.fill"
        case .stats: return "chart.bar"
        case .profile: return "person"
        }
    }
}

public struct MainTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedTab: AppTab = .home
    @State private var isPresentingManualLog: Bool = false
    @State private var isPresentingSettings: Bool = false
    @State private var isPresentingAuth: Bool = false
    @State private var authInitialStep: AuthStep = .accountManagement

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Global Botanical Wallpaper Background (Image 4 across all screens)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Screen content switching based on selectedTab
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        viewModel: HomeViewModel(
                            getDailySummaryUseCase: environment.getDailySummaryUseCase,
                            mealRepository: environment.mealRepository,
                            userRepository: environment.userRepository
                        ),
                        onScanTapped: {
                            selectedTab = .scan
                        },
                        onLogManualTapped: {
                            isPresentingManualLog = true
                        },
                        onOpenSettings: {
                            isPresentingSettings = true
                        },
                        onQuickLogDish: { item in
                            let meal = MealRecord(mealType: .lunch, items: [item])
                            Task {
                                try? await environment.logMealUseCase.execute(meal: meal)
                            }
                        },
                        onOpenDiary: {
                            selectedTab = .history
                        }
                    )

                case .scan:
                    FoodRecognitionView(
                        viewModel: FoodRecognitionViewModel(
                            recognizeFoodUseCase: environment.recognizeFoodUseCase,
                            logMealUseCase: environment.logMealUseCase
                        ),
                        onMealSaved: { _ in
                            // Seamlessly switch to Meal Diary to inspect the logged meal
                            selectedTab = .history
                        },
                        onDismiss: {
                            selectedTab = .home
                        }
                    )

                case .history:
                    MealHistoryView(
                        viewModel: MealHistoryViewModel(
                            getMealHistoryUseCase: environment.getMealHistoryUseCase
                        )
                    )

                case .stats:
                    NutritionAnalyticsView(
                        viewModel: NutritionAnalyticsViewModel(
                            getNutritionAnalyticsUseCase: environment.getNutritionAnalyticsUseCase
                        )
                    )

                case .profile:
                    ProfileView(
                        viewModel: ProfileViewModel(
                            userRepository: environment.userRepository,
                            authenticationRepository: environment.authenticationRepository
                        ),
                        onOpenSettings: {
                            isPresentingSettings = true
                        },
                        onOpenAccount: {
                            isPresentingAuth = true
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Floating Bottom Navigation Bar (Matching Visual Reference)
            CustomFloatingTabBar(
                selectedTab: $selectedTab,
                onScanTapped: {
                    selectedTab = .scan
                }
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isPresentingManualLog) {
            LogMealView(
                viewModel: LogMealViewModel(
                    logMealUseCase: environment.logMealUseCase,
                    onDismiss: { isPresentingManualLog = false }
                ),
                onCancel: { isPresentingManualLog = false }
            )
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView(onOpenAccount: {
                isPresentingAuth = true
            })
        }
        .sheet(isPresented: $isPresentingAuth) {
            AuthCoordinatorView(
                viewModel: environment.makeAuthViewModel(
                    initialStep: ProcessInfo.processInfo.arguments.contains("-startAuthWelcome") ? .welcome : authInitialStep,
                    onAuthCompleted: {
                        isPresentingAuth = false
                    }
                ),
                onDismiss: {
                    isPresentingAuth = false
                }
            )
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-startTabProfile") {
                selectedTab = .profile
            } else if ProcessInfo.processInfo.arguments.contains("-startAccountSecurity") {
                selectedTab = .profile
                authInitialStep = .accountManagement
                isPresentingAuth = true
            } else if ProcessInfo.processInfo.arguments.contains("-startAuthWelcome") {
                authInitialStep = .welcome
                isPresentingAuth = true
            }
        }
    }
}

// MARK: - Custom Floating Tab Bar
private struct CustomFloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let onScanTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Tab 1: Trang chủ
            TabBarItemButton(
                title: "Trang chủ",
                icon: "house.fill",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            // Tab 2: Nhật ký (Open book outline matching reference)
            TabBarItemButton(
                title: "Nhật ký",
                icon: "book",
                isSelected: selectedTab == .history
            ) {
                selectedTab = .history
            }

            // Tab 3 (Center Elevated Button): Quét with Viewfinder Brackets
            Button {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                onScanTapped()
            } label: {
                VStack(spacing: 3) {
                    ZStack {
                        // White opaque protective dome backing (prevents any scroll content or text from showing behind button)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 58, height: 58)
                            .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.72, blue: 0.44), // #38B770
                                        Color(red: 0.10, green: 0.58, blue: 0.34)  // #1A9457
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(color: Color(red: 0.12, green: 0.58, blue: 0.34).opacity(0.38), radius: 8, x: 0, y: 4)

                        // Viewfinder 4 corner brackets + camera icon matching reference
                        ZStack {
                            CornerBracketsShape(bracketLength: 6.5, cornerRadius: 2.5)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                                .frame(width: 25, height: 25)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -14)

                    Text("Quét")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.18))
                        .offset(y: -12)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            // Tab 4: Thống kê
            TabBarItemButton(
                title: "Thống kê",
                icon: "chart.bar",
                isSelected: selectedTab == .stats
            ) {
                selectedTab = .stats
            }

            // Tab 5: Cá nhân
            TabBarItemButton(
                title: "Cá nhân",
                icon: "person",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 10)
        .background(
            FloatingTabBarShape()
                .fill(Color.white)
        )
        .overlay(
            FloatingTabBarShape()
                .stroke(Color(red: 0.93, green: 0.95, blue: 0.94), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Shapes for Floating Tab Bar
private struct FloatingTabBarShape: Shape {
    var cornerRadius: CGFloat = 34
    var bumpHeight: CGFloat = 16
    var bumpWidth: CGFloat = 80

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let r = cornerRadius
        let cx = w / 2
        let halfBump = bumpWidth / 2

        path.move(to: CGPoint(x: r, y: 0))

        // Left straight top edge
        path.addLine(to: CGPoint(x: cx - halfBump, y: 0))

        // Smooth cubic hill over center button
        path.addCurve(
            to: CGPoint(x: cx, y: -bumpHeight),
            control1: CGPoint(x: cx - halfBump + 18, y: 0),
            control2: CGPoint(x: cx - 20, y: -bumpHeight)
        )
        path.addCurve(
            to: CGPoint(x: cx + halfBump, y: 0),
            control1: CGPoint(x: cx + 20, y: -bumpHeight),
            control2: CGPoint(x: cx + halfBump - 18, y: 0)
        )

        // Right straight top edge
        path.addLine(to: CGPoint(x: w - r, y: 0))

        // Top-right corner
        path.addArc(
            center: CGPoint(x: w - r, y: r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: w, y: h - r))

        // Bottom-right corner
        path.addArc(
            center: CGPoint(x: w - r, y: h - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: r, y: h))

        // Bottom-left corner
        path.addArc(
            center: CGPoint(x: r, y: h - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: r))

        // Top-left corner
        path.addArc(
            center: CGPoint(x: r, y: r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

private struct CornerBracketsShape: Shape {
    var bracketLength: CGFloat = 7
    var cornerRadius: CGFloat = 2.5

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

private struct TabBarItemButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.12, green: 0.60, blue: 0.35) : Color(red: 0.35, green: 0.40, blue: 0.45))
                    .frame(height: 24)

                Text(title)
                    .font(.system(size: 10.5, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(red: 0.12, green: 0.60, blue: 0.35) : Color(red: 0.35, green: 0.40, blue: 0.45))

                // Active Indicator bar under selected tab
                if isSelected {
                    Capsule()
                        .fill(Color(red: 0.12, green: 0.60, blue: 0.35))
                        .frame(width: 24, height: 3)
                        .padding(.top, 1)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 24, height: 3)
                        .padding(.top, 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
