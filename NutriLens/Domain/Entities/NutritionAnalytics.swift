//
//  NutritionAnalytics.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Domain models for Nutrition Analytics V2: Period types, time-series data points,
//  macronutrient energy distributions, category contributions, and explainable insights.
//

import Foundation

public enum AnalyticsPeriodType: String, CaseIterable, Identifiable, Sendable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .day: return "Ngày"
        case .week: return "Tuần"
        case .month: return "Tháng"
        }
    }
}

public struct DailyCaloriePoint: Identifiable, Equatable, Sendable {
    public let id: String
    public let date: Date
    public let shortLabel: String      // e.g. "T2", "3", "03/11"
    public let fullDateLabel: String    // e.g. "Thứ Ba, 03 Th11"
    public let calories: Double
    public let targetCalories: Double
    public let hasRecords: Bool
    public let proteinGrams: Double
    public let carbGrams: Double
    public let fatGrams: Double
    public let fiberGrams: Double
    public let mealCount: Int

    public init(
        id: String,
        date: Date,
        shortLabel: String,
        fullDateLabel: String,
        calories: Double,
        targetCalories: Double,
        hasRecords: Bool,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double = 0,
        mealCount: Int = 0
    ) {
        self.id = id
        self.date = date
        self.shortLabel = shortLabel
        self.fullDateLabel = fullDateLabel
        self.calories = calories
        self.targetCalories = targetCalories
        self.hasRecords = hasRecords
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.mealCount = mealCount
    }
}

public struct CategoryCalorieBreakdown: Identifiable, Equatable, Sendable {
    public var id: String { category.rawValue }
    public let category: MealType
    public let calories: Double
    public let percentage: Double // 0.0 .. 1.0
    public let mealCount: Int

    public init(category: MealType, calories: Double, percentage: Double, mealCount: Int) {
        self.category = category
        self.calories = calories
        self.percentage = percentage
        self.mealCount = mealCount
    }
}

public struct MacroDistribution: Equatable, Sendable {
    public let proteinGrams: Double
    public let carbGrams: Double
    public let fatGrams: Double
    public let fiberGrams: Double

    public var proteinCalories: Double { proteinGrams * 4.0 }
    public var carbCalories: Double { carbGrams * 4.0 }
    public var fatCalories: Double { fatGrams * 9.0 }
    public var totalEnergyCalories: Double { proteinCalories + carbCalories + fatCalories }

    public var proteinPercentage: Double {
        totalEnergyCalories > 0 ? (proteinCalories / totalEnergyCalories) : 0
    }

    public var carbPercentage: Double {
        totalEnergyCalories > 0 ? (carbCalories / totalEnergyCalories) : 0
    }

    public var fatPercentage: Double {
        totalEnergyCalories > 0 ? (fatCalories / totalEnergyCalories) : 0
    }

    public init(proteinGrams: Double, carbGrams: Double, fatGrams: Double, fiberGrams: Double) {
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }
}

public enum InsightType: String, Sendable {
    case goalAchievement
    case loggingConsistency
    case macroBalance
    case fiberAdequacy
    case mealDistribution
}

public struct NutritionInsight: Identifiable, Equatable, Sendable {
    public let id: String
    public let type: InsightType
    public let title: String
    public let message: String
    public let icon: String
    public let isPositive: Bool

    public init(id: String = UUID().uuidString, type: InsightType, title: String, message: String, icon: String, isPositive: Bool) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.icon = icon
        self.isPositive = isPositive
    }
}

public struct PeriodAnalyticsData: Equatable, Sendable {
    public let periodType: AnalyticsPeriodType
    public let startDate: Date
    public let endDate: Date
    public let formattedPeriodTitle: String

    public let totalCalories: Double
    public let dailyAverageCalories: Double
    public let targetCalories: Double
    public let previousPeriodCalories: Double?
    public let calorieChangePercentage: Double? // +5.2% vs previous period

    public let dailyPoints: [DailyCaloriePoint]
    public let categoryBreakdown: [CategoryCalorieBreakdown]
    public let macroDistribution: MacroDistribution

    public let totalProtein: Double
    public let targetProtein: Double
    public let dailyAverageProtein: Double

    public let totalCarbs: Double
    public let targetCarbs: Double
    public let dailyAverageCarbs: Double

    public let totalFat: Double
    public let targetFat: Double
    public let dailyAverageFat: Double

    public let totalFiber: Double
    public let targetFiber: Double
    public let dailyAverageFiber: Double

    public let recordedDaysCount: Int
    public let totalDaysInPeriod: Int
    public let insights: [NutritionInsight]

    public init(
        periodType: AnalyticsPeriodType,
        startDate: Date,
        endDate: Date,
        formattedPeriodTitle: String,
        totalCalories: Double,
        dailyAverageCalories: Double,
        targetCalories: Double,
        previousPeriodCalories: Double?,
        calorieChangePercentage: Double?,
        dailyPoints: [DailyCaloriePoint],
        categoryBreakdown: [CategoryCalorieBreakdown],
        macroDistribution: MacroDistribution,
        totalProtein: Double,
        targetProtein: Double,
        dailyAverageProtein: Double,
        totalCarbs: Double,
        targetCarbs: Double,
        dailyAverageCarbs: Double,
        totalFat: Double,
        targetFat: Double,
        dailyAverageFat: Double,
        totalFiber: Double,
        targetFiber: Double,
        dailyAverageFiber: Double,
        recordedDaysCount: Int,
        totalDaysInPeriod: Int,
        insights: [NutritionInsight]
    ) {
        self.periodType = periodType
        self.startDate = startDate
        self.endDate = endDate
        self.formattedPeriodTitle = formattedPeriodTitle
        self.totalCalories = totalCalories
        self.dailyAverageCalories = dailyAverageCalories
        self.targetCalories = targetCalories
        self.previousPeriodCalories = previousPeriodCalories
        self.calorieChangePercentage = calorieChangePercentage
        self.dailyPoints = dailyPoints
        self.categoryBreakdown = categoryBreakdown
        self.macroDistribution = macroDistribution
        self.totalProtein = totalProtein
        self.targetProtein = targetProtein
        self.dailyAverageProtein = dailyAverageProtein
        self.totalCarbs = totalCarbs
        self.targetCarbs = targetCarbs
        self.dailyAverageCarbs = dailyAverageCarbs
        self.totalFat = totalFat
        self.targetFat = targetFat
        self.dailyAverageFat = dailyAverageFat
        self.totalFiber = totalFiber
        self.targetFiber = targetFiber
        self.dailyAverageFiber = dailyAverageFiber
        self.recordedDaysCount = recordedDaysCount
        self.totalDaysInPeriod = totalDaysInPeriod
        self.insights = insights
    }
}
