//
//  AppSpacing.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Strictly conforms to design system scale: 4, 8, 12, 16, 24, 32 pt.
//

import SwiftUI

public enum AppSpacing {
    /// 4 pt - Micro spacing between closely associated labels/icons
    public static let xxs: CGFloat = 4
    /// 8 pt - Compact element padding
    public static let xs: CGFloat = 8
    /// 12 pt - Standard inner card item spacing
    public static let sm: CGFloat = 12
    /// 16 pt - Default section element spacing
    public static let md: CGFloat = 16
    /// 20 pt - Mandatory standard horizontal screen gutter padding
    public static let screenHorizontal: CGFloat = 20
    /// 24 pt - Major component block separation
    public static let lg: CGFloat = 24
    /// 32 pt - Section & screen title margin
    public static let xl: CGFloat = 32
    /// 48 pt - Generous container & dock margin
    public static let xxl: CGFloat = 48
}
