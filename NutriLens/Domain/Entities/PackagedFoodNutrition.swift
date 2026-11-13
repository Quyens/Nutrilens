//
//  PackagedFoodNutrition.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Encapsulates nutritional declarations for packaged consumer food goods.
//  NOTE: Preserves nil for optional/unlisted micronutrients without converting to 0.
//

import Foundation

public enum NutritionBasis: String, Codable, CaseIterable, Sendable {
    case perServing = "Khẩu phần (Serving)"
    case per100g = "Mỗi 100g"
    case per100ml = "Mỗi 100ml"

    public var shortLabel: String {
        switch self {
        case .perServing: return "Khẩu phần"
        case .per100g: return "100g"
        case .per100ml: return "100ml"
        }
    }
}

public struct PackagedFoodServing: Codable, Equatable, Hashable, Sendable {
    public var servingSize: Double
    public var servingUnit: String
    public var servingsPerPackage: Double?
    public var servingGramsEquivalent: Double

    public init(
        servingSize: Double = 100,
        servingUnit: String = "g",
        servingsPerPackage: Double? = 1.0,
        servingGramsEquivalent: Double? = nil
    ) {
        self.servingSize = max(1.0, servingSize)
        self.servingUnit = servingUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "g" : servingUnit
        self.servingsPerPackage = servingsPerPackage
        self.servingGramsEquivalent = servingGramsEquivalent ?? max(1.0, servingSize)
    }

    public var displayTitle: String {
        let sizeInt = Int(servingSize)
        let isInt = (servingSize == Double(sizeInt))
        let sizeStr = isInt ? "\(sizeInt)" : String(format: "%.1f", servingSize)
        return "\(sizeStr) \(servingUnit)"
    }
}

public struct PackagedFoodNutrition: Codable, Equatable, Hashable, Sendable {
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double?
    public var sodiumMg: Double?
    public var sugarGrams: Double?
    public var calciumMg: Double?
    public var ironMg: Double?
    public var basis: NutritionBasis

    public init(
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double? = nil,
        sodiumMg: Double? = nil,
        sugarGrams: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        basis: NutritionBasis = .perServing
    ) {
        self.calories = max(0, calories)
        self.proteinGrams = max(0, proteinGrams)
        self.carbGrams = max(0, carbGrams)
        self.fatGrams = max(0, fatGrams)
        self.fiberGrams = fiberGrams.map { max(0, $0) }
        self.sodiumMg = sodiumMg.map { max(0, $0) }
        self.sugarGrams = sugarGrams.map { max(0, $0) }
        self.calciumMg = calciumMg.map { max(0, $0) }
        self.ironMg = ironMg.map { max(0, $0) }
        self.basis = basis
    }

    /// Scales nutrition values by a portion multiplier without corrupting nil micronutrients
    public func scaled(by multiplier: Double) -> PackagedFoodNutrition {
        let factor = max(0.01, multiplier)
        return PackagedFoodNutrition(
            calories: (calories * factor * 10).rounded() / 10,
            proteinGrams: (proteinGrams * factor * 10).rounded() / 10,
            carbGrams: (carbGrams * factor * 10).rounded() / 10,
            fatGrams: (fatGrams * factor * 10).rounded() / 10,
            fiberGrams: fiberGrams.map { (($0 * factor) * 10).rounded() / 10 },
            sodiumMg: sodiumMg.map { (($0 * factor) * 10).rounded() / 10 },
            sugarGrams: sugarGrams.map { (($0 * factor) * 10).rounded() / 10 },
            calciumMg: calciumMg.map { (($0 * factor) * 10).rounded() / 10 },
            ironMg: ironMg.map { (($0 * factor) * 10).rounded() / 10 },
            basis: basis
        )
    }

    /// Converts nutrition declared per 100g to a specific serving quantity
    public func toServingNutrition(servingGrams: Double) -> PackagedFoodNutrition {
        guard basis == .per100g || basis == .per100ml else { return self }
        let factor = max(0.01, servingGrams) / 100.0
        var converted = scaled(by: factor)
        converted.basis = .perServing
        return converted
    }
}

