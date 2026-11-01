//
//  AppRouter.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case scan = 1
    case history = 2
    case profile = 3

    public var id: Int { rawValue }

    public var title: LocalizedStringKey {
        switch self {
        case .home: return "Home"
        case .scan: return "Scan"
        case .history: return "History"
        case .profile: return "Profile"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .scan: return "camera.viewfinder"
        case .history: return "clock.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

public struct MainTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedTab: AppTab = .home
    @State private var isPresentingManualLog: Bool = false
    @State private var isPresentingSettings: Bool = false

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
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
                onQuickLogDish: { item in
                    let meal = MealRecord(mealType: .lunch, items: [item])
                    Task {
                        try? await environment.logMealUseCase.execute(meal: meal)
                    }
                }
            )
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }
            .tag(AppTab.home)

            FoodRecognitionView(
                viewModel: FoodRecognitionViewModel(
                    recognizeFoodUseCase: environment.recognizeFoodUseCase
                ),
                onResultConfirmed: { foodItem in
                    let meal = MealRecord(mealType: .lunch, items: [foodItem])
                    Task {
                        try? await environment.logMealUseCase.execute(meal: meal)
                        selectedTab = .home
                    }
                }
            )
            .tabItem {
                Label(AppTab.scan.title, systemImage: AppTab.scan.icon)
            }
            .tag(AppTab.scan)

            MealHistoryView(
                viewModel: MealHistoryViewModel(
                    getMealHistoryUseCase: environment.getMealHistoryUseCase
                )
            )
            .tabItem {
                Label(AppTab.history.title, systemImage: AppTab.history.icon)
            }
            .tag(AppTab.history)

            ProfileView(
                viewModel: ProfileViewModel(
                    userRepository: environment.userRepository
                ),
                onOpenSettings: {
                    isPresentingSettings = true
                }
            )
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
            }
            .tag(AppTab.profile)
        }
        .tint(AppColors.primary)
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
            SettingsView()
        }
    }
}
