//
//  DietaryPreferenceType.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents optional user dietary lifestyles without enforcing restrictive medical diets.
//

import Foundation

public enum DietaryPreferenceType: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case vietnamese = "vietnamese"
    case vegetarian = "vegetarian"
    case lowCarb = "low_carb"
    case highProtein = "high_protein"
    case balanced = "balanced"
    case pescatarian = "pescatarian"
    case eatClean = "eat_clean"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .vietnamese:
            return "Món Việt 3 miền"
        case .vegetarian:
            return "Ăn chay / Thuần chay"
        case .lowCarb:
            return "Keto / Low-Carb"
        case .highProtein:
            return "Giàu Đạm (Protein)"
        case .balanced:
            return "Cân bằng dinh dưỡng"
        case .pescatarian:
            return "Pescatarian (Có hải sản)"
        case .eatClean:
            return "Eat Clean / Thanh đạm"
        }
    }

    public var subtitle: String {
        switch self {
        case .vietnamese:
            return "Ưu tiên ẩm thực truyền thống & đặc sản địa phương"
        case .vegetarian:
            return "Tự động ưu tiên món chay, không dùng thịt động vật"
        case .lowCarb:
            return "Hạn chế tinh bột đơn, tăng cường chất xơ và đạm"
        case .highProtein:
            return "Ưu tiên các món cung cấp từ 25g protein trở lên"
        case .balanced:
            return "Tỉ lệ năng lượng đa lượng hài hòa theo khuyến nghị NIN"
        case .pescatarian:
            return "Ăn chay kết hợp cá & hải sản, không ăn thịt gia súc/gia cầm"
        case .eatClean:
            return "Ưu tiên thực phẩm nguyên bản, chế biến đơn giản, ít gia vị đậm"
        }
    }

    public var systemIcon: String {
        switch self {
        case .vietnamese: return "fork.knife"
        case .vegetarian: return "leaf.fill"
        case .lowCarb: return "bolt.fill"
        case .highProtein: return "figure.strengthtraining.traditional"
        case .balanced: return "scale.3d"
        case .pescatarian: return "fish.fill"
        case .eatClean: return "sparkles"
        }
    }
}

