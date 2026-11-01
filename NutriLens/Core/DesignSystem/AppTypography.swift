//
//  AppTypography.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppTypography {
    public static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    public static let title1 = Font.system(.title, design: .rounded).weight(.bold)
    public static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    public static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    public static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    public static let subheadline = Font.system(.subheadline, design: .default).weight(.medium)
    public static let body = Font.system(.body, design: .default)
    public static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
    public static let callout = Font.system(.callout, design: .default)
    public static let footnote = Font.system(.footnote, design: .default)
    public static let caption = Font.system(.caption, design: .default)
    public static let captionBold = Font.system(.caption, design: .default).weight(.semibold)

    // Numbers & Metrics (Monospaced digits for stability during updates)
    public static let metricLarge = Font.system(size: 38, weight: .bold, design: .rounded).monospacedDigit()
    public static let metricMedium = Font.system(size: 24, weight: .bold, design: .rounded).monospacedDigit()
    public static let metricSmall = Font.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit()
}
