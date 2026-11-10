//
//  HapticFeedbackService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Centralized haptic feedback service that respects user preferences in Settings.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public protocol HapticFeedbackServiceProtocol: Sendable {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func selection()
}

@MainActor
public final class HapticFeedbackService: HapticFeedbackServiceProtocol {
    public static let shared = HapticFeedbackService()

    private let userDefaultsKey = "hapticFeedbackEnabled"

    public var isHapticsEnabled: Bool {
        // Default to true if not explicitly set
        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    public init() {}

    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        #if canImport(UIKit)
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if canImport(UIKit)
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
        #endif
    }

    public func selection() {
        #if canImport(UIKit)
        guard isHapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }
}
