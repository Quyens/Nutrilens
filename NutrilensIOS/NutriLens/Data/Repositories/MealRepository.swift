//
//  MealRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftData

public final class MealRepository: MealRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    @MainActor
    public func fetchMeals(for date: Date) async throws -> [MealRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<MealSDModel>(
            predicate: #Predicate<MealSDModel> {
                $0.timestamp >= startOfDay && $0.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.dataPersistenceFailed("Fetch failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchMeals(from startDate: Date, to endDate: Date) async throws -> [MealRecord] {
        let start = startDate
        let end = endDate
        let descriptor = FetchDescriptor<MealSDModel>(
            predicate: #Predicate<MealSDModel> {
                $0.timestamp >= start && $0.timestamp <= end
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.dataPersistenceFailed("Fetch failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchAllMeals() async throws -> [MealRecord] {
        let descriptor = FetchDescriptor<MealSDModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.dataPersistenceFailed("Fetch failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func saveMeal(_ meal: MealRecord) async throws {
        let sdModel = MealSDModel(from: meal)
        container.mainContext.insert(sdModel)
        do {
            try container.mainContext.save()
            AppLogger.data.info("Saved meal: \(meal.id) with \(meal.items.count) items.")
        } catch {
            throw AppError.dataPersistenceFailed("Save failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func updateMeal(_ meal: MealRecord) async throws {
        let mealId = meal.id
        let descriptor = FetchDescriptor<MealSDModel>(
            predicate: #Predicate<MealSDModel> { $0.id == mealId }
        )
        do {
            if let target = try container.mainContext.fetch(descriptor).first {
                target.timestamp = meal.timestamp
                target.mealTypeRaw = meal.mealType.rawValue
                target.notes = meal.notes
                target.imagePath = meal.imagePath
                for item in target.items {
                    container.mainContext.delete(item)
                }
                target.items = meal.items.map { FoodItemSDModel(from: $0) }
                try container.mainContext.save()
                AppLogger.data.info("Updated meal: \(meal.id)")
            } else {
                try await saveMeal(meal)
            }
        } catch {
            throw AppError.dataPersistenceFailed("Update failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func deleteMeal(id: UUID) async throws {
        let descriptor = FetchDescriptor<MealSDModel>(
            predicate: #Predicate<MealSDModel> { $0.id == id }
        )
        do {
            if let target = try container.mainContext.fetch(descriptor).first {
                container.mainContext.delete(target)
                try container.mainContext.save()
            }
        } catch {
            throw AppError.dataPersistenceFailed("Delete failed: \(error.localizedDescription)")
        }
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
            targetCalories: 2000,
            consumedProteinGrams: totalProtein,
            targetProteinGrams: 130,
            consumedCarbGrams: totalCarbs,
            targetCarbGrams: 220,
            consumedFatGrams: totalFat,
            targetFatGrams: 65,
            consumedFiberGrams: totalFiber,
            targetFiberGrams: 30
        )
    }
}
