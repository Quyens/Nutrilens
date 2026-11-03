//
//  FoodExplorerCategory.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Taxonomy and filter categories for the Vietnamese Food Database & Explorer V1.
//

import Foundation

public enum FoodExplorerCategory: String, CaseIterable, Identifiable, Sendable {
    case all = "Tất cả"
    case noodleSoup = "Món nước"
    case rice = "Cơm & Xôi"
    case noodles = "Bún / Phở"
    case pastry = "Bánh"
    case snacks = "Món ăn nhẹ"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .noodleSoup: return "cup.and.saucer.fill"
        case .rice: return "leaf.circle.fill"
        case .noodles: return "fork.knife"
        case .pastry: return "birthday.cake.fill"
        case .snacks: return "sparkles"
        }
    }

    /// Determines if a given dish profile belongs to this category filter
    public func matches(profile: VietnameseDishProfile) -> Bool {
        switch self {
        case .all:
            return true

        case .noodleSoup:
            return profile.category == "Món Nước" || profile.category == "Canh" || profile.slug.contains("canh")

        case .rice:
            return profile.category == "Cơm" || profile.category == "Xôi" || profile.category == "Món Mặn" || profile.slug.contains("com") || profile.slug.contains("xoi")

        case .noodles:
            return profile.category == "Bún & Mì" || profile.slug.contains("pho") || profile.slug.contains("bun") || profile.slug.contains("mi") || profile.slug.contains("hu_tieu")

        case .pastry:
            return profile.category == "Món Bánh" || profile.category == "Bánh Mì" || profile.slug.contains("banh")

        case .snacks:
            return profile.category == "Khai Vị" || profile.category == "Tráng Miệng" || profile.slug.contains("che") || profile.slug.contains("cuon")
        }
    }
}
