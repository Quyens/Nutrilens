//
//  AppColors.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Strictly centralized brand palette & semantic design tokens.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum AppColors {
    // MARK: - Core Brand Palette (Bright Premium Health + Fresh & Vibrant)
    public static let canvasBackground = Color(hex: "FCFDF9")
    public static let mintSurface = Color(hex: "E9F6E9")
    public static let primaryGreen = Color(hex: "35A968")
    public static let softGreen = Color(hex: "B9E6C5")
    public static let peachOrange = Color(hex: "FFB978")
    public static let softCoral = Color(hex: "F5C6C2")
    public static let proteinBlue = Color(hex: "6CA9E8")
    public static let carbsOrange = Color(hex: "F3A34B")
    public static let fatCoral = Color(hex: "E97970")
    public static let textPrimaryDark = Color(hex: "233B2D")
    public static let textSecondaryMuted = Color(hex: "819187")
    public static let borderGreenLight = Color(hex: "E8EEE7")

    // Backward compatibility aliases
    public static let warmIvory = canvasBackground
    public static let forestGreen = primaryGreen
    public static let sageGreen = softGreen
    public static let accentSage = primaryGreen
    public static let warmGold = carbsOrange
    public static let dividerLight = borderGreenLight

    // MARK: - Semantic Tokens (Adaptive Light & Dark Mode)

    /// Background: #FCFDF9 in Light Mode, deep clean slate in Dark Mode.
    public static var background: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.06, green: 0.10, blue: 0.08, alpha: 1.0)
                : UIColor(red: 0.988, green: 0.992, blue: 0.976, alpha: 1.0) // #FCFDF9
        })
        #else
        canvasBackground
        #endif
    }

    /// Primary surface: Pure white card in Light Mode, elevated clean forest in Dark Mode.
    public static var surfacePrimary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.16, blue: 0.13, alpha: 1.0)
                : UIColor.white
        })
        #else
        Color.white
        #endif
    }

    /// Secondary surface: Fresh Mint Surface (#E9F6E9) in Light Mode.
    public static var surfaceSecondary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.20, blue: 0.16, alpha: 1.0)
                : UIColor(red: 0.914, green: 0.965, blue: 0.914, alpha: 1.0) // #E9F6E9
        })
        #else
        mintSurface
        #endif
    }

    /// Surface aliases for compatibility
    public static var surface: Color { surfacePrimary }
    public static var cardBackground: Color { surfacePrimary }
    public static var elevatedSurface: Color { surfaceSecondary }
    public static var primarySubtle: Color { surfaceSecondary }

    /// Primary text: High-contrast deep pine (#233B2D) in Light Mode, Bright Ivory in Dark Mode.
    public static var textPrimary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.98, green: 0.99, blue: 0.98, alpha: 1.0)
                : UIColor(red: 0.137, green: 0.231, blue: 0.176, alpha: 1.0) // #233B2D
        })
        #else
        textPrimaryDark
        #endif
    }

    /// Secondary text: Muted sage (#819187) in Light Mode.
    public static var textSecondary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.68, green: 0.76, blue: 0.71, alpha: 1.0)
                : UIColor(red: 0.506, green: 0.569, blue: 0.529, alpha: 1.0) // #819187
        })
        #else
        textSecondaryMuted
        #endif
    }

    /// Tertiary text: Subtle caption & timestamp indicator.
    public static var textTertiary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.52, green: 0.60, blue: 0.55, alpha: 1.0)
                : UIColor(red: 0.62, green: 0.68, blue: 0.64, alpha: 1.0)
        })
        #else
        Color.gray
        #endif
    }

    /// Primary action button background: Vibrant Primary Green (#35A968).
    public static var primaryAction: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.28, green: 0.72, blue: 0.46, alpha: 1.0)
                : UIColor(red: 0.208, green: 0.663, blue: 0.408, alpha: 1.0) // #35A968
        })
        #else
        primaryGreen
        #endif
    }

    /// Brand aliases
    public static var primary: Color { primaryAction }
    public static var primaryDark: Color { primaryGreen }
    public static var primaryLight: Color { softGreen }

    /// Text color on primary action button.
    public static var primaryActionText: Color {
        Color.white
    }

    /// Subtle card and row border (#E8EEE7).
    public static var border: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.18, green: 0.26, blue: 0.22, alpha: 1.0)
                : UIColor(red: 0.910, green: 0.933, blue: 0.906, alpha: 1.0) // #E8EEE7
        })
        #else
        borderGreenLight
        #endif
    }

    /// Divider lines.
    public static var divider: Color { border }
    public static var borderSubtle: Color { border }
    public static var shadowSubtle: Color { Color.black.opacity(0.03) }

    /// Disabled state representation.
    public static var disabled: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.28, blue: 0.24, alpha: 1.0)
                : UIColor(red: 0.85, green: 0.88, blue: 0.85, alpha: 1.0)
        })
        #else
        Color.gray.opacity(0.3)
        #endif
    }

    // MARK: - Nutrition Semantic Accents (Bright & Distinctive)
    public static let calorieGold = primaryGreen
    public static let calorieGreen = primaryGreen
    public static let proteinOcean = proteinBlue
    public static let carbAmber = carbsOrange
    public static let fatCoralAccent = fatCoral

    public static var calories: Color { calorieGreen }
    public static var protein: Color { proteinBlue }
    public static var carbs: Color { carbsOrange }
    public static var fat: Color { fatCoralAccent }

    // MARK: - Status Indicators
    public static let success = primaryGreen
    public static let warning = carbsOrange
    public static let error = fatCoral
    public static let info = proteinBlue

    // MARK: - Subtle Gradients
    public static let primaryGradient = LinearGradient(
        colors: [primaryGreen, Color(hex: "278B53")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let subtleGlowGradient = RadialGradient(
        gradient: Gradient(colors: [
            softGreen.opacity(0.14),
            Color.clear
        ]),
        center: .top,
        startRadius: 20,
        endRadius: 400
    )
}

// MARK: - Hex Initializer Extension
private extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}
