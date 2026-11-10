//
//  SwiftDataEntities.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftData

@Model
public final class FoodItemSDModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var vietnameseName: String
    public var confidence: Double
    public var servingSizeGrams: Double
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double

    public init(
        id: UUID = UUID(),
        name: String,
        vietnameseName: String,
        confidence: Double,
        servingSizeGrams: Double,
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double
    ) {
        self.id = id
        self.name = name
        self.vietnameseName = vietnameseName
        self.confidence = confidence
        self.servingSizeGrams = servingSizeGrams
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }

    public convenience init(from entity: FoodItem) {
        self.init(
            id: entity.id,
            name: entity.name,
            vietnameseName: entity.vietnameseName,
            confidence: entity.confidence,
            servingSizeGrams: entity.servingSizeGrams,
            calories: entity.calories,
            proteinGrams: entity.proteinGrams,
            carbGrams: entity.carbGrams,
            fatGrams: entity.fatGrams,
            fiberGrams: entity.fiberGrams
        )
    }

    public func toDomain() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            vietnameseName: vietnameseName,
            confidence: confidence,
            servingSizeGrams: servingSizeGrams,
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams
        )
    }
}

@Model
public final class MealSDModel {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var mealTypeRaw: String
    @Relationship(deleteRule: .cascade) public var items: [FoodItemSDModel]
    public var notes: String?
    public var imagePath: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealTypeRaw: String,
        items: [FoodItemSDModel] = [],
        notes: String? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealTypeRaw = mealTypeRaw
        self.items = items
        self.notes = notes
        self.imagePath = imagePath
    }

    public convenience init(from domain: MealRecord) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            mealTypeRaw: domain.mealType.rawValue,
            items: domain.items.map { FoodItemSDModel(from: $0) },
            notes: domain.notes,
            imagePath: domain.imagePath
        )
    }

    public func toDomain() -> MealRecord {
        let mealType = MealType(rawValue: mealTypeRaw) ?? .breakfast
        return MealRecord(
            id: id,
            timestamp: timestamp,
            mealType: mealType,
            items: items.map { $0.toDomain() },
            notes: notes,
            imagePath: imagePath
        )
    }
}

@Model
public final class HydrationRecordSDModel {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var amountLiters: Double
    public var notes: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amountLiters: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountLiters = amountLiters
        self.notes = notes
    }

    public convenience init(from domain: HydrationRecord) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            amountLiters: domain.amountLiters,
            notes: domain.notes
        )
    }

    public func toDomain() -> HydrationRecord {
        HydrationRecord(
            id: id,
            timestamp: timestamp,
            amountLiters: amountLiters,
            notes: notes
        )
    }
}
