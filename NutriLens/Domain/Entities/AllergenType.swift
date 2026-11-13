//
//  AllergenType.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents common allergen groups recognized in food safety guidelines.
//

import Foundation

public enum AllergenType: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case peanuts = "peanuts"
    case shellfish = "shellfish"
    case fish = "fish"
    case eggs = "eggs"
    case milk = "milk"
    case soy = "soy"
    case gluten = "gluten"
    case sesame = "sesame"
    case treeNuts = "tree_nuts"

    public var id: String { rawValue }

    public var vietnameseName: String {
        switch self {
        case .peanuts:
            return "Đậu phộng / Lạc"
        case .shellfish:
            return "Hải sản có vỏ (Tôm, Cua, Sò)"
        case .fish:
            return "Cá & Chế phẩm cá"
        case .eggs:
            return "Trứng gia cầm"
        case .milk:
            return "Sữa & Lactose"
        case .soy:
            return "Đậu nành & Đậu hũ"
        case .gluten:
            return "Lúa mì & Gluten"
        case .sesame:
            return "Mè / Vừng"
        case .treeNuts:
            return "Hạt cây (Điều, Hạnh nhân...)"
        }
    }

    public var shortName: String {
        switch self {
        case .peanuts: return "Đậu phộng"
        case .shellfish: return "Hải sản"
        case .fish: return "Cá"
        case .eggs: return "Trứng"
        case .milk: return "Sữa"
        case .soy: return "Đậu nành"
        case .gluten: return "Gluten"
        case .sesame: return "Mè"
        case .treeNuts: return "Hạt cây"
        }
    }

    public var systemIcon: String {
        switch self {
        case .peanuts: return "circle.grid.2x1.fill"
        case .shellfish: return "tortoise.fill"
        case .fish: return "fish.fill"
        case .eggs: return "oval.fill"
        case .milk: return "cup.and.saucer.fill"
        case .soy: return "leaf.circle.fill"
        case .gluten: return "allergens"
        case .sesame: return "circle.circle"
        case .treeNuts: return "leaf.arrow.circlepath"
        }
    }

    public var riskDescription: String {
        switch self {
        case .peanuts:
            return "Thường gặp trong tương chấm gỏi cuốn, bánh tráng nướng, xôi, các món nộm trộn."
        case .shellfish:
            return "Thường gặp trong mắm tôm, mắm ruốc bún bò huế, bánh canh, gỏi cuốn tôm thịt."
        case .fish:
            return "Thường có mặt trong nước mắm cốt truyền thống, bún mắm, cá kho, canh chua."
        case .eggs:
            return "Thường gặp trong chả trứng cơm tấm, bánh mì chảo, bánh xèo, các loại bánh hấp."
        case .milk:
            return "Thường có trong cà phê sữa, bánh pía sầu riêng, các loại chè và tráng miệng."
        case .soy:
            return "Thường có trong nước tương, đậu hũ chiên, chao, các món chay và sốt ướp."
        case .gluten:
            return "Có trong bánh mì baguette, mì trứng, bột chiên giòn, hủ tiếu mì."
        case .sesame:
            return "Thường được rắc trên xôi, chè, bánh đa, các loại bánh ngọt truyền thống."
        case .treeNuts:
            return "Có trong một số loại chè ngũ hạt, nhân bánh trung thu, granola."
        }
    }
}

