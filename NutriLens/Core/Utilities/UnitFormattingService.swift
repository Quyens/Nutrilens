//
//  UnitFormattingService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Formatting service converting canonical metric values into preferred display units (Metric vs Imperial).
//

import Foundation

public protocol UnitFormattingServiceProtocol: Sendable {
    var isMetric: Bool { get }
    func formatWeight(grams: Double) -> String
    func formatVolume(liters: Double) -> String
    func formatCalories(_ calories: Double) -> String
    func weightUnitLabel() -> String
    func volumeUnitLabel() -> String
}

public final class UnitFormattingService: UnitFormattingServiceProtocol, @unchecked Sendable {
    public static let shared = UnitFormattingService()

    private let userDefaultsKey = "useMetricUnits"

    public var isMetric: Bool {
        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    public init() {}

    public func formatWeight(grams: Double) -> String {
        if isMetric {
            return "\(Int(round(grams))) g"
        } else {
            let ounces = grams / 28.3495231
            return String(format: "%.1f oz", ounces)
        }
    }

    public func formatVolume(liters: Double) -> String {
        if isMetric {
            if liters < 1.0 {
                let ml = Int(round(liters * 1000))
                return "\(ml) ml"
            } else {
                return String(format: "%.1f L", liters)
            }
        } else {
            let flOz = liters * 33.8140226
            return String(format: "%.1f fl oz", flOz)
        }
    }

    public func formatCalories(_ calories: Double) -> String {
        return "\(Int(round(calories))) kcal"
    }

    public func weightUnitLabel() -> String {
        return isMetric ? "g" : "oz"
    }

    public func volumeUnitLabel() -> String {
        return isMetric ? "ml" : "fl oz"
    }
}
