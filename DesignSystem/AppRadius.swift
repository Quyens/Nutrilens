//
//  AppRadius.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppRadius {
    /// 4 pt - Micro badge radius
    public static let xs: CGFloat = 4
    /// 8 pt - Small chip / tag radius
    public static let sm: CGFloat = 8
    /// 12 pt - Intermediate container radius
    public static let md: CGFloat = 12
    /// 16 pt - Mandatory standard button radius
    public static let button: CGFloat = 16
    /// 20 pt - Mandatory standard card radius
    public static let card: CGFloat = 20
    /// 24 pt - Modal sheet & hero container radius
    public static let sheet: CGFloat = 24
    public static let cardLarge: CGFloat = 24
    /// Capsule / Pill radius
    public static let pill: CGFloat = 999

    public static let lg: CGFloat = card
    public static let xl: CGFloat = sheet
    public static let xxl: CGFloat = pill

    public static let medium: CGFloat = md
    public static let large: CGFloat = card
}
