//
//  PortionCalculationService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Safe portion scaling and nutrition calculation service for Food Database & Explorer V1.
//

import Foundation

public struct ScaledNutrition: Equatable, Sendable {
    public let servingGrams: Double
    public let calories: Double
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let fiber: Double
    public let scaleFactor: Double

    public init(
        servingGrams: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double,
        scaleFactor: Double
    ) {
        self.servingGrams = servingGrams
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.scaleFactor = scaleFactor
    }
}

public enum PortionPreset: CaseIterable, Identifiable {
    case half
    case standard
    case large
    case double

    public var id: String { title }

    public var title: String {
        switch self {
        case .half: return "0.5x"
        case .standard: return "1.0x"
        case .large: return "1.5x"
        case .double: return "2.0x"
        }
    }

    public var label: String {
        switch self {
        case .half: return "Nửa phần"
        case .standard: return "Tiêu chuẩn"
        case .large: return "Phần lớn"
        case .double: return "Gấp đôi"
        }
    }

    public var multiplier: Double {
        switch self {
        case .half: return 0.5
        case .standard: return 1.0
        case .large: return 1.5
        case .double: return 2.0
        }
    }
}

public enum PortionCalculationService {
    public static let minGrams: Double = 10.0
    public static let maxGrams: Double = 2000.0
    public static let nutritionDisclaimer: String = "Giá trị dinh dưỡng là ước tính tham khảo, có thể dao động tùy theo công thức chế biến và tỷ lệ nguyên liệu thực tế."

    public static func scale(profile: VietnameseDishProfile, targetGrams: Double) -> ScaledNutrition {
        let baseGrams = max(1.0, profile.standardServingGrams)
        let clampedGrams: Double
        if targetGrams.isNaN || targetGrams < minGrams {
            clampedGrams = minGrams
        } else if targetGrams > maxGrams {
            clampedGrams = maxGrams
        } else {
            clampedGrams = targetGrams
        }

        let factor = clampedGrams / baseGrams

        let cal = (profile.caloriesPerServing * factor).rounded()
        let p = ((profile.proteinPerServing * factor) * 10).rounded() / 10
        let c = ((profile.carbPerServing * factor) * 10).rounded() / 10
        let f = ((profile.fatPerServing * factor) * 10).rounded() / 10
        let fib = ((profile.fiberPerServing * factor) * 10).rounded() / 10

        return ScaledNutrition(
            servingGrams: clampedGrams,
            calories: max(0, cal),
            protein: max(0, p),
            carbs: max(0, c),
            fat: max(0, f),
            fiber: max(0, fib),
            scaleFactor: factor
        )
    }
}
