//
//  MockMealRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  IMPORTANT: This is a test/preview mock repository strictly used for SwiftUI Previews
//  and deterministic automated Unit/UI testing. It is NOT real user data.
//

import Foundation

public final class MockMealRepository: MealRepositoryProtocol, @unchecked Sendable {
    private var storage: [MealRecord] = []
    private let lock = NSLock()

    public init(initialMeals: [MealRecord]? = nil) {
        if let initialMeals {
            self.storage = initialMeals
        } else {
            self.storage = Self.sampleMeals
        }
    }

    public func fetchMeals(for date: Date) async throws -> [MealRecord] {
        lock.lock()
        defer { lock.unlock() }
        let calendar = Calendar.current
        return storage.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    public func fetchMeals(from startDate: Date, to endDate: Date) async throws -> [MealRecord] {
        lock.lock()
        defer { lock.unlock() }
        return storage.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    public func fetchAllMeals() async throws -> [MealRecord] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    public func saveMeal(_ meal: MealRecord) async throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll { $0.id == meal.id }
        storage.insert(meal, at: 0)
    }

    public func updateMeal(_ meal: MealRecord) async throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll { $0.id == meal.id }
        storage.insert(meal, at: 0)
    }

    public func deleteMeal(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll { $0.id == id }
    }

    public func fetchDailySummary(for date: Date) async throws -> NutritionSummary {
        let meals = try await fetchMeals(for: date)
        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = meals.reduce(0) { $0 + $1.totalProteinGrams }
        let totalCarbs = meals.reduce(0) { $0 + $1.totalCarbGrams }
        let totalFat = meals.reduce(0) { $0 + $1.totalFatGrams }
        let totalFiber = meals.reduce(0) { $0 + $1.totalFiberGrams }

        return NutritionSummary(
            date: date,
            consumedCalories: totalCalories,
            targetCalories: 2100,
            consumedProteinGrams: totalProtein,
            targetProteinGrams: 140,
            consumedCarbGrams: totalCarbs,
            targetCarbGrams: 230,
            consumedFatGrams: totalFat,
            targetFatGrams: 60,
            consumedFiberGrams: totalFiber,
            targetFiberGrams: 32
        )
    }

    // MARK: - Deterministic Preview/Test Mock Data
    public static let sampleMeals: [MealRecord] = [
        MealRecord(
            timestamp: Date(),
            mealType: .breakfast,
            items: [
                FoodItem(
                    name: "Vietnamese Beef Pho",
                    vietnameseName: "Phở Bò Tái",
                    confidence: 0.94,
                    servingSizeGrams: 450,
                    calories: 480,
                    proteinGrams: 32,
                    carbGrams: 62,
                    fatGrams: 12,
                    fiberGrams: 3
                )
            ],
            notes: "Traditional breakfast bowl with fresh herbs"
        ),
        MealRecord(
            timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
            mealType: .lunch,
            items: [
                FoodItem(
                    name: "Broken Rice with Grilled Pork",
                    vietnameseName: "Cơm Tấm Sườn Nướng",
                    confidence: 0.91,
                    servingSizeGrams: 400,
                    calories: 620,
                    proteinGrams: 38,
                    carbGrams: 75,
                    fatGrams: 18,
                    fiberGrams: 4
                )
            ],
            notes: "Served with pickled veggies and fish sauce"
        )
    ]
}
