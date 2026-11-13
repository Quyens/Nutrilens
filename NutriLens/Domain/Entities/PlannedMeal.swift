//
//  PlannedMeal.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents a planned meal scheduled on a specific calendar date and category.
//

import Foundation

public enum PlannedMealCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    public var id: String { rawValue }

    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    public var vietnameseName: String {
        switch self {
        case .breakfast: return "Bữa sáng"
        case .lunch: return "Bữa trưa"
        case .dinner: return "Bữa tối"
        case .snack: return "Bữa phụ"
        }
    }

    public var systemIcon: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }

    public var toMealType: MealType {
        switch self {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }

    public static func from(mealType: MealType) -> PlannedMealCategory {
        switch mealType {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }
}

public enum PlannedMealStatus: String, CaseIterable, Codable, Sendable {
    case planned = "planned"
    case completed = "completed"
    case skipped = "skipped"

    public var vietnameseTitle: String {
        switch self {
        case .planned: return "Kế hoạch"
        case .completed: return "Đã ăn"
        case .skipped: return "Bỏ qua"
        }
    }

    public var systemIcon: String {
        switch self {
        case .planned: return "calendar"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "slash.circle"
        }
    }
}

public struct PlannedMeal: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var scheduledDate: Date
    public var mealCategory: PlannedMealCategory
    public var foodItems: [PlannedFoodItem]
    public var notes: String?
    public var status: PlannedMealStatus
    public var linkedDiaryRecordId: UUID?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        scheduledDate: Date,
        mealCategory: PlannedMealCategory,
        foodItems: [PlannedFoodItem] = [],
        notes: String? = nil,
        status: PlannedMealStatus = .planned,
        linkedDiaryRecordId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.mealCategory = mealCategory
        self.foodItems = foodItems
        self.notes = notes
        self.status = status
        self.linkedDiaryRecordId = linkedDiaryRecordId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Total planned nutritional summary from all contained items
    public var totalNutrition: PlannedNutritionSnapshot {
        foodItems.reduce(.zero) { $0 + $1.nutritionSnapshot }
    }

    public var totalCalories: Double {
        totalNutrition.calories
    }

    public var totalProteinGrams: Double {
        totalNutrition.proteinGrams
    }

    public var totalCarbGrams: Double {
        totalNutrition.carbGrams
    }

    public var totalFatGrams: Double {
        totalNutrition.fatGrams
    }

    public var totalFiberGrams: Double {
        totalNutrition.fiberGrams
    }

    /// Summary description of dish names
    public var itemsSummaryText: String {
        if foodItems.isEmpty {
            return "Chưa có món nào"
        }
        return foodItems.map { $0.displayName }.joined(separator: ", ")
    }

    /// Creates an independent copy of this meal scheduled for a new date, reset to `.planned`
    public func duplicate(forDate newDate: Date) -> PlannedMeal {
        PlannedMeal(
            id: UUID(),
            scheduledDate: newDate,
            mealCategory: mealCategory,
            foodItems: foodItems.map { item in
                PlannedFoodItem(
                    id: UUID(),
                    sourceType: item.sourceType,
                    sourceId: item.sourceId,
                    displayName: item.displayName,
                    quantity: item.quantity,
                    servingUnit: item.servingUnit,
                    portionMultiplier: item.portionMultiplier,
                    nutritionSnapshot: item.nutritionSnapshot
                )
            },
            notes: notes,
            status: .planned,
            linkedDiaryRecordId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

