//
//  AppTypography.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Strictly conforms to SF system typography scale with Dynamic Type support.
//

import SwiftUI

public enum AppTypography {
    /// Hero title: Large bold branding display (Dynamic Type: .largeTitle)
    public static let heroTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    public static let largeTitle = heroTitle

    /// Screen title: Primary top-level navigation title (Dynamic Type: .title)
    public static let screenTitle = Font.system(.title, design: .default).weight(.bold)
    public static let title = screenTitle
    public static let title1 = screenTitle

    /// Secondary Title: Sub-section headers (Dynamic Type: .title2)
    public static let title2 = Font.system(.title2, design: .default).weight(.semibold)

    /// Section title: Header for logical content groups (Dynamic Type: .title3)
    public static let sectionTitle = Font.system(.title3, design: .default).weight(.semibold)
    public static let title3 = sectionTitle

    /// Card title: Key headline inside container cards (Dynamic Type: .headline)
    public static let cardTitle = Font.system(.headline, design: .default).weight(.semibold)
    public static let headline = cardTitle
    public static let headlineBold = Font.system(.headline, design: .default).weight(.bold)

    /// Body: Standard readable text for descriptions and content (Dynamic Type: .body)
    public static let body = Font.system(.body, design: .default)

    /// Body Bold: Emphasized body text (Dynamic Type: .body)
    public static let bodyBold = Font.system(.body, design: .default).weight(.semibold)

    /// Subheadline: Secondary context line (Dynamic Type: .subheadline)
    public static let subheadline = Font.system(.subheadline, design: .default).weight(.regular)
    public static let subheadlineBold = Font.system(.subheadline, design: .default).weight(.semibold)

    /// Footnote: Tertiary contextual note (Dynamic Type: .footnote)
    public static let footnote = Font.system(.footnote, design: .default)

    /// Caption: Small metadata tags and indicators (Dynamic Type: .caption)
    public static let caption = Font.system(.caption, design: .default)

    /// Caption Bold: Badge and chip indicators (Dynamic Type: .caption)
    public static let captionBold = Font.system(.caption, design: .default).weight(.semibold)

    /// Nutrition values: Monospaced numeric digits to eliminate horizontal jitter during live updates
    public static let nutritionValueLarge = Font.system(size: 34, weight: .bold, design: .default).monospacedDigit()
    public static let nutritionValueMedium = Font.system(size: 22, weight: .bold, design: .default).monospacedDigit()
    public static let nutritionValueSmall = Font.system(size: 15, weight: .semibold, design: .default).monospacedDigit()

    public static let metricLarge = nutritionValueLarge
    public static let metricMedium = nutritionValueMedium
    public static let metricSmall = nutritionValueSmall
}
