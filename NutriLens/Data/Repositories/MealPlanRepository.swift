//
//  MealPlanRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  SwiftData-backed implementation of MealPlanRepositoryProtocol.
//

import Foundation
import SwiftData

public final class MealPlanRepository: MealPlanRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer
    private let calendarHelper: MealPlanCalendarHelper

    public init(
        container: ModelContainer = SwiftDataStack.shared.container,
        calendarHelper: MealPlanCalendarHelper = MealPlanCalendarHelper()
    ) {
        self.container = container
        self.calendarHelper = calendarHelper

        Task { @MainActor in
            self.seedInitialPlansIfNeeded()
        }
    }

    @MainActor
    private var context: ModelContext {
        container.mainContext
    }

    public func getPlannedMeals(forWeekStarting weekStartDate: Date, weekEndDate: Date) async throws -> [PlannedMeal] {
        try await MainActor.run {
            let start = calendarHelper.startOfDay(for: weekStartDate)
            let end = weekEndDate
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.scheduledDate >= start && $0.scheduledDate <= end },
                sortBy: [SortDescriptor(\.scheduledDate, order: .forward)]
            )
            let models = try context.fetch(descriptor)
            return models.map { $0.toDomain() }
        }
    }

    public func getPlannedMeals(forDay date: Date) async throws -> [PlannedMeal] {
        try await MainActor.run {
            let start = calendarHelper.startOfDay(for: date)
            guard let end = calendarHelper.calendar.date(bySettingHour: 23, minute: 59, second: 59, of: start) else {
                return []
            }
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.scheduledDate >= start && $0.scheduledDate <= end },
                sortBy: [SortDescriptor(\.scheduledDate, order: .forward)]
            )
            let models = try context.fetch(descriptor)
            return models.map { $0.toDomain() }
        }
    }

    public func getPlannedMeal(byId id: UUID) async throws -> PlannedMeal? {
        try await MainActor.run {
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            return try context.fetch(descriptor).first?.toDomain()
        }
    }

    public func savePlannedMeal(_ meal: PlannedMeal) async throws {
        try await MainActor.run {
            // Check if existing model exists to update or insert new
            let id = meal.id
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                existing.scheduledDate = meal.scheduledDate
                existing.mealCategoryRaw = meal.mealCategory.rawValue
                existing.notes = meal.notes
                existing.statusRaw = meal.status.rawValue
                existing.linkedDiaryRecordId = meal.linkedDiaryRecordId
                existing.updatedAt = Date()
                existing.foodItems = meal.foodItems.map { PlannedFoodItemSDModel(from: $0) }
            } else {
                let model = PlannedMealSDModel(from: meal)
                context.insert(model)
            }
            try context.save()
        }
    }

    public func updatePlannedMeal(_ meal: PlannedMeal) async throws {
        try await savePlannedMeal(meal)
    }

    public func deletePlannedMeal(id: UUID) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            if let model = try context.fetch(descriptor).first {
                context.delete(model)
                try context.save()
            }
        }
    }

    public func markMealCompleted(id: UUID, linkedDiaryRecordId: UUID) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            if let model = try context.fetch(descriptor).first {
                model.statusRaw = PlannedMealStatus.completed.rawValue
                model.linkedDiaryRecordId = linkedDiaryRecordId
                model.updatedAt = Date()
                try context.save()
            }
        }
    }

    public func markMealSkipped(id: UUID) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            if let model = try context.fetch(descriptor).first {
                model.statusRaw = PlannedMealStatus.skipped.rawValue
                model.updatedAt = Date()
                try context.save()
            }
        }
    }

    public func restorePlannedStatus(id: UUID) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<PlannedMealSDModel>(
                predicate: #Predicate { $0.id == id }
            )
            if let model = try context.fetch(descriptor).first {
                model.statusRaw = PlannedMealStatus.planned.rawValue
                model.linkedDiaryRecordId = nil
                model.updatedAt = Date()
                try context.save()
            }
        }
    }

    public func getWeeklyPlan(forWeekContaining date: Date) async throws -> WeeklyMealPlan {
        let monday = calendarHelper.startOfWeek(for: date)
        let sunday = calendarHelper.endOfWeek(for: date)
        let meals = try await getPlannedMeals(forWeekStarting: monday, weekEndDate: sunday)
        return WeeklyMealPlan(
            weekStartDate: monday,
            weekEndDate: sunday,
            plannedMeals: meals
        )
    }

    // MARK: - Initial Seeding
    @MainActor
    private func seedInitialPlansIfNeeded() {
        var descriptor = FetchDescriptor<PlannedMealSDModel>()
        descriptor.fetchLimit = 10
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count <= 1 else { return }

        let today = Date()
        let monday = calendarHelper.startOfWeek(for: today)

        // Seed realistic planned meals across the current week
        let sampleDishes = VietnameseNutritionDatabase.dishes

        func dishItem(_ slug: String, grams: Double? = nil) -> PlannedFoodItem? {
            guard let d = sampleDishes.first(where: { $0.slug == slug }) else { return nil }
            return PlannedFoodItem.fromVietnameseDish(d, quantityGrams: grams ?? d.standardServingGrams)
        }

        var initialMeals: [PlannedMeal] = []

        // Day 1 (Monday)
        let day1 = monday
        if let pho = dishItem("pho") {
            initialMeals.append(PlannedMeal(
                scheduledDate: day1,
                mealCategory: .breakfast,
                foodItems: [pho],
                notes: "Ăn sáng thanh đạm đầu tuần"
            ))
        }
        if let comTam = dishItem("com_tam") {
            initialMeals.append(PlannedMeal(
                scheduledDate: day1,
                mealCategory: .lunch,
                foodItems: [comTam],
                notes: "Bữa trưa công sở"
            ))
        }
        if let canhChua = dishItem("canh_chua"), let caKho = dishItem("ca_kho_to") {
            initialMeals.append(PlannedMeal(
                scheduledDate: day1,
                mealCategory: .dinner,
                foodItems: [canhChua, caKho],
                notes: "Cơm gia đình"
            ))
        }

        // Day 2 (Tuesday)
        if let day2 = calendarHelper.calendar.date(byAdding: .day, value: 1, to: monday) {
            if let banhMi = dishItem("banh_mi") {
                initialMeals.append(PlannedMeal(
                    scheduledDate: day2,
                    mealCategory: .breakfast,
                    foodItems: [banhMi],
                    notes: "Bánh mì giòn rụm"
                ))
            }
            if let bunCha = dishItem("bun_cha") {
                initialMeals.append(PlannedMeal(
                    scheduledDate: day2,
                    mealCategory: .lunch,
                    foodItems: [bunCha],
                    notes: "Bún chả Hà Nội đậm đà"
                ))
            }
        }

        // Day 3 (Wednesday)
        if let day3 = calendarHelper.calendar.date(byAdding: .day, value: 2, to: monday) {
            if let xoi = dishItem("xoi") {
                initialMeals.append(PlannedMeal(
                    scheduledDate: day3,
                    mealCategory: .breakfast,
                    foodItems: [xoi]
                ))
            }
            if let bunBo = dishItem("bun_bo_hue") {
                initialMeals.append(PlannedMeal(
                    scheduledDate: day3,
                    mealCategory: .lunch,
                    foodItems: [bunBo]
                ))
            }
        }

        for meal in initialMeals {
            let model = PlannedMealSDModel(from: meal)
            context.insert(model)
        }
        try? context.save()
        AppLogger.data.info("Seeded initial planned meals for week: \(initialMeals.count) meals.")
    }
}
