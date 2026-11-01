//
//  AppColors.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppColors {
    // MARK: - Brand & Accents
    /// Emerald Green - Core brand color symbolizing freshness, vitality, and nutrition.
    public static let primary = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    public static let primaryDark = Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)
    public static let primaryLight = Color(red: 110 / 255, green: 231 / 255, blue: 183 / 255)
    public static let primarySubtle = Color(red: 236 / 255, green: 253 / 255, blue: 245 / 255)
    public static let accentMint = Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255)

    // MARK: - Gradients
    public static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255),
            Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let subtleGlowGradient = RadialGradient(
        gradient: Gradient(colors: [
            Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255).opacity(0.18),
            Color.clear
        ]),
        center: .top,
        startRadius: 20,
        endRadius: 360
    )

    public static let cardSelectedGradient = LinearGradient(
        colors: [
            Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255).opacity(0.12),
            Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255).opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Macronutrient Semantic Palette
    public static let protein = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)   // Ocean Blue
    public static let carbs = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)     // Amber Gold
    public static let fat = Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)        // Coral Crimson
    public static let calories = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)  // Emerald

    // MARK: - Surfaces & Backgrounds (Adaptive Light / Dark)
    public static var background: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
        #endif
    }

    public static var surface: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color.white
        #endif
    }

    public static var elevatedSurface: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiarySystemGroupedBackground)
        #else
        Color.white
        #endif
    }

    // MARK: - Content & Typography
    public static var textPrimary: Color {
        #if canImport(UIKit)
        Color(uiColor: .label)
        #else
        Color.black
        #endif
    }

    public static var textSecondary: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondaryLabel)
        #else
        Color.gray
        #endif
    }

    public static var textTertiary: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiaryLabel)
        #else
        Color.secondary
        #endif
    }

    // MARK: - Borders & Dividers
    public static var border: Color {
        #if canImport(UIKit)
        Color(uiColor: .separator)
        #else
        Color.gray.opacity(0.2)
        #endif
    }

    // MARK: - Status
    public static let success = Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
    public static let warning = Color(red: 234 / 255, green: 179 / 255, blue: 8 / 255)
    public static let error = Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)
    public static let info = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
}
