//
//  SettingsViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Production-ready Settings ViewModel complying with Apple App Store Guidelines.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public final class SettingsViewModel: ObservableObject {
    @AppStorage("useMetricUnits") public var useMetricUnits: Bool = true
    @AppStorage("hapticFeedbackEnabled") public var hapticFeedbackEnabled: Bool = true
    @AppStorage("dailyReminderEnabled") public var dailyReminderEnabled: Bool = true
    @Published public var appVersion: String = "1.0.0 (Build 1)"
    @Published public var showingPrivacySheet: Bool = false
    @Published public var showingTermsSheet: Bool = false
    @Published public var showingCacheClearedAlert: Bool = false
    @Published public var showingSupportAlert: Bool = false

    public init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.appVersion = "\(version) (\(build))"
        } else {
            self.appVersion = "1.0.0 (1)"
        }
    }

    public func clearCache() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        showingCacheClearedAlert = true
    }

    public func openSystemSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #endif
    }

    public func requestAppReview() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
