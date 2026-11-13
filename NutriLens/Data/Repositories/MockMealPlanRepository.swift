//
//  MockMealPlanRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  In-memory mock implementation of MealPlanRepositoryProtocol for unit testing and previews.
//

import Foundation

public final class MockMealPlanRepository: MealPlanRepositoryProtocol, @unchecked Sendable {
    private var plannedMeals: [PlannedMeal]
    private let calendarHelper: MealPlanCalendarHelper

    public init(
        initialMeals: [PlannedMeal] = [],
        seedInitial: Bool = true,
        calendarHelper: MealPlanCalendarHelper = MealPlanCalendarHelper()
    ) {
        self.plannedMeals = initialMeals
        self.calendarHelper = calendarHelper

        if initialMeals.isEmpty && seedInitial {
            self.seedMockMeals()
        }
    }

    public func getPlannedMeals(forWeekStarting weekStartDate: Date, weekEndDate: Date) async throws -> [PlannedMeal] {
        let start = calendarHelper.startOfDay(for: weekStartDate)
        return plannedMeals.filter {
            $0.scheduledDate >= start && $0.scheduledDate <= weekEndDate
        }.sorted { $0.scheduledDate < $1.scheduledDate }
    }

    public func getPlannedMeals(forDay date: Date) async throws -> [PlannedMeal] {
        plannedMeals.filter {
            calendarHelper.isSameDay($0.scheduledDate, date)
        }.sorted { $0.createdAt < $1.createdAt }
    }

    public func getPlannedMeal(byId id: UUID) async throws -> PlannedMeal? {
        plannedMeals.first(where: { $0.id == id })
    }

    public func savePlannedMeal(_ meal: PlannedMeal) async throws {
        if let index = plannedMeals.firstIndex(where: { $0.id == meal.id }) {
            plannedMeals[index] = meal
        } else {
            plannedMeals.append(meal)
        }
    }

    public func updatePlannedMeal(_ meal: PlannedMeal) async throws {
        try await savePlannedMeal(meal)
    }

    public func deletePlannedMeal(id: UUID) async throws {
        plannedMeals.removeAll(where: { $0.id == id })
    }

    public func markMealCompleted(id: UUID, linkedDiaryRecordId: UUID) async throws {
        guard let index = plannedMeals.firstIndex(where: { $0.id == id }) else {
            throw AppError.itemNotFound
        }
        var meal = plannedMeals[index]
        meal.status = .completed
        meal.linkedDiaryRecordId = linkedDiaryRecordId
        meal.updatedAt = Date()
        plannedMeals[index] = meal
    }

    public func markMealSkipped(id: UUID) async throws {
        guard let index = plannedMeals.firstIndex(where: { $0.id == id }) else {
            throw AppError.itemNotFound
        }
        var meal = plannedMeals[index]
        meal.status = .skipped
        meal.updatedAt = Date()
        plannedMeals[index] = meal
    }

    public func restorePlannedStatus(id: UUID) async throws {
        guard let index = plannedMeals.firstIndex(where: { $0.id == id }) else {
            throw AppError.itemNotFound
        }
        var meal = plannedMeals[index]
        meal.status = .planned
        meal.linkedDiaryRecordId = nil
        meal.updatedAt = Date()
        plannedMeals[index] = meal
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

    private func seedMockMeals() {
        let today = Date()
        let monday = calendarHelper.startOfWeek(for: today)
        let dishes = VietnameseNutritionDatabase.dishes

        func makeItem(_ slug: String, grams: Double? = nil) -> PlannedFoodItem? {
            guard let d = dishes.first(where: { $0.slug == slug }) else { return nil }
            return PlannedFoodItem.fromVietnameseDish(d, quantityGrams: grams ?? d.standardServingGrams)
        }

        // Today's Breakfast
        if let pho = makeItem("pho") {
            plannedMeals.append(PlannedMeal(
                scheduledDate: today,
                mealCategory: .breakfast,
                foodItems: [pho],
                notes: "Bữa sáng giàu protein"
            ))
        }

        // Today's Lunch
        if let comTam = makeItem("com-tam") {
            plannedMeals.append(PlannedMeal(
                scheduledDate: today,
                mealCategory: .lunch,
                foodItems: [comTam],
                notes: "Cơm trưa văn phòng"
            ))
        }

        // Today's Dinner
        if let canhChua = makeItem("canh-chua"), let caKho = makeItem("ca-kho-to") {
            plannedMeals.append(PlannedMeal(
                scheduledDate: today,
                mealCategory: .dinner,
                foodItems: [canhChua, caKho],
                notes: "Cơm tối gia đình"
            ))
        }

        // Day after today
        if let tomorrow = calendarHelper.calendar.date(byAdding: .day, value: 1, to: today) {
            if let banhMi = makeItem("banh-mi") {
                plannedMeals.append(PlannedMeal(
                    scheduledDate: tomorrow,
                    mealCategory: .breakfast,
                    foodItems: [banhMi]
                ))
            }
            if let bunCha = makeItem("bun-cha") {
                plannedMeals.append(PlannedMeal(
                    scheduledDate: tomorrow,
                    mealCategory: .lunch,
                    foodItems: [bunCha]
                ))
            }
        }
    }
}
