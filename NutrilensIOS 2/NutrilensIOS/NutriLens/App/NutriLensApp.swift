//
//  NutriLensApp.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI
import SwiftData

@main
struct NutriLensApp: App {
    @StateObject private var environment: AppEnvironment
    @State private var isOnboardingCompleted: Bool = true
    private let swiftDataStack = SwiftDataStack.shared

    init() {
        // Detect if running under XCTest
        let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        if isRunningTests {
            _environment = StateObject(wrappedValue: AppEnvironment.mock())
        } else {
            _environment = StateObject(wrappedValue: AppEnvironment.live())
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboardingCompleted {
                    MainTabView()
                        .environmentObject(environment)
                } else {
                    OnboardingView(
                        viewModel: OnboardingViewModel(
                            userRepository: environment.userRepository,
                            onComplete: {
                                isOnboardingCompleted = true
                            }
                        )
                    )
                    .environmentObject(environment)
                }
            }
            .task {
                if let profile = try? await environment.userRepository.getUserProfile() {
                    isOnboardingCompleted = profile.isOnboardingCompleted
                }
            }
        }
        .modelContainer(swiftDataStack.container)
    }
}
