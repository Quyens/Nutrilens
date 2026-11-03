//
//  MealRecord.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public enum MealType: String, CaseIterable, Codable, Sendable, Identifiable {
    public var id: String { rawValue }

    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    public var systemIcon: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }

    public var vietnameseName: String {
        switch self {
        case .breakfast: return "Bữa sáng"
        case .lunch: return "Bữa trưa"
        case .dinner: return "Bữa tối"
        case .snack: return "Bữa phụ"
        }
    }
}

public struct MealRecord: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let mealType: MealType
    public let items: [FoodItem]
    public let notes: String?
    public let imagePath: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealType: MealType,
        items: [FoodItem],
        notes: String? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealType = mealType
        self.items = items
        self.notes = notes
        self.imagePath = imagePath
    }

    public var totalCalories: Double {
        items.reduce(0) { $0 + $1.calories }
    }

    public var totalProteinGrams: Double {
        items.reduce(0) { $0 + $1.proteinGrams }
    }

    public var totalCarbGrams: Double {
        items.reduce(0) { $0 + $1.carbGrams }
    }

    public var totalFatGrams: Double {
        items.reduce(0) { $0 + $1.fatGrams }
    }

    public var totalFiberGrams: Double {
        items.reduce(0) { $0 + $1.fiberGrams }
    }

    public var totalServingGrams: Double {
        items.reduce(0) { $0 + $1.servingSizeGrams }
    }

    public var displayTitle: String {
        let names = items.map(\.vietnameseName).filter { !$0.isEmpty }
        if names.isEmpty {
            return "Bữa ăn dinh dưỡng"
        }
        return names.joined(separator: ", ")
    }
}
