//
//  SettingsViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class SettingsViewModel: ObservableObject {
    @AppStorage("useMetricUnits") public var useMetricUnits: Bool = true
    @AppStorage("hapticFeedbackEnabled") public var hapticFeedbackEnabled: Bool = true
    @Published public var appVersion: String = "1.0.0 (Build 1)"

    public init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.appVersion = "\(version) (\(build))"
        }
    }
}
