//
//  MicronutrientProfile.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents optional vitamins and minerals for detailed nutritional tracking.
//

import Foundation

public struct MicronutrientProfile: Codable, Equatable, Hashable, Sendable {
    public var sodiumMg: Double?
    public var potassiumMg: Double?
    public var calciumMg: Double?
    public var ironMg: Double?
    public var vitaminAMcg: Double?
    public var vitaminCMg: Double?
    public var sugarGrams: Double?
    public var cholesterolMg: Double?

    public init(
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminAMcg: Double? = nil,
        vitaminCMg: Double? = nil,
        sugarGrams: Double? = nil,
        cholesterolMg: Double? = nil
    ) {
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.vitaminAMcg = vitaminAMcg
        self.vitaminCMg = vitaminCMg
        self.sugarGrams = sugarGrams
        self.cholesterolMg = cholesterolMg
    }

    /// Scales micronutrients proportionally by a multiplication ratio
    public func scaled(by ratio: Double) -> MicronutrientProfile {
        MicronutrientProfile(
            sodiumMg: sodiumMg.map { (($0 * ratio) * 10).rounded() / 10 },
            potassiumMg: potassiumMg.map { (($0 * ratio) * 10).rounded() / 10 },
            calciumMg: calciumMg.map { (($0 * ratio) * 10).rounded() / 10 },
            ironMg: ironMg.map { (($0 * ratio) * 10).rounded() / 10 },
            vitaminAMcg: vitaminAMcg.map { (($0 * ratio) * 10).rounded() / 10 },
            vitaminCMg: vitaminCMg.map { (($0 * ratio) * 10).rounded() / 10 },
            sugarGrams: sugarGrams.map { (($0 * ratio) * 10).rounded() / 10 },
            cholesterolMg: cholesterolMg.map { (($0 * ratio) * 10).rounded() / 10 }
        )
    }

    /// Combines two micronutrient profiles additively
    public static func + (lhs: MicronutrientProfile, rhs: MicronutrientProfile) -> MicronutrientProfile {
        func sumOptional(_ a: Double?, _ b: Double?) -> Double? {
            if let a, let b { return a + b }
            return a ?? b
        }

        return MicronutrientProfile(
            sodiumMg: sumOptional(lhs.sodiumMg, rhs.sodiumMg),
            potassiumMg: sumOptional(lhs.potassiumMg, rhs.potassiumMg),
            calciumMg: sumOptional(lhs.calciumMg, rhs.calciumMg),
            ironMg: sumOptional(lhs.ironMg, rhs.ironMg),
            vitaminAMcg: sumOptional(lhs.vitaminAMcg, rhs.vitaminAMcg),
            vitaminCMg: sumOptional(lhs.vitaminCMg, rhs.vitaminCMg),
            sugarGrams: sumOptional(lhs.sugarGrams, rhs.sugarGrams),
            cholesterolMg: sumOptional(lhs.cholesterolMg, rhs.cholesterolMg)
        )
    }

    /// Combines two optional micronutrient profiles safely, returning nil if both are nil
    public static func combine(_ lhs: MicronutrientProfile?, _ rhs: MicronutrientProfile?) -> MicronutrientProfile? {
        guard lhs != nil || rhs != nil else { return nil }
        guard let lhs else { return rhs }
        guard let rhs else { return lhs }
        return lhs + rhs
    }

    public var hasAnyData: Bool {
        sodiumMg != nil || potassiumMg != nil || calciumMg != nil ||
        ironMg != nil || vitaminAMcg != nil || vitaminCMg != nil ||
        sugarGrams != nil || cholesterolMg != nil
    }
}
