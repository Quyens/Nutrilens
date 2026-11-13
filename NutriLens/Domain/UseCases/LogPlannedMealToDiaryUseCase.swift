//
//  LogPlannedMealToDiaryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Executes atomic conversion of a PlannedMeal into an immutable MealRecord in the Meal Diary.
//

import Foundation

public protocol LogPlannedMealToDiaryUseCaseProtocol: Sendable {
    /// Logs a planned meal to the actual meal diary with optional food items adjustment
    @discardableResult
    func execute(
        plannedMeal: PlannedMeal,
        actualFoodItems: [FoodItem]?,
        loggedDate: Date,
        mealType: MealType?,
        notes: String?
    ) async throws -> MealRecord
}

public final class LogPlannedMealToDiaryUseCase: LogPlannedMealToDiaryUseCaseProtocol {
    private let mealPlanRepository: MealPlanRepositoryProtocol
    private let mealRepository: MealRepositoryProtocol

    public init(
        mealPlanRepository: MealPlanRepositoryProtocol,
        mealRepository: MealRepositoryProtocol
    ) {
        self.mealPlanRepository = mealPlanRepository
        self.mealRepository = mealRepository
    }

    @discardableResult
    public func execute(
        plannedMeal: PlannedMeal,
        actualFoodItems: [FoodItem]? = nil,
        loggedDate: Date = Date(),
        mealType: MealType? = nil,
        notes: String? = nil
    ) async throws -> MealRecord {
        // 1. Prevent duplicate logging if already completed and linked to a diary record
        if plannedMeal.status == .completed, let existingDiaryId = plannedMeal.linkedDiaryRecordId {
            throw AppError.invalidInput("Bữa ăn này đã được ghi vào nhật ký trước đó (ID: \(existingDiaryId)).")
        }

        // 2. Prepare items: use provided corrected items, or convert from planned food items
        let itemsToLog: [FoodItem]
        if let actualItems = actualFoodItems, !actualItems.isEmpty {
            itemsToLog = actualItems
        } else {
            itemsToLog = plannedMeal.foodItems.map { $0.toFoodItem() }
        }

        guard !itemsToLog.isEmpty else {
            throw AppError.invalidInput("Không thể ghi bữa ăn rỗng vào nhật ký.")
        }

        // 3. Construct concrete MealRecord
        let targetMealType = mealType ?? plannedMeal.mealCategory.toMealType
        let mealRecord = MealRecord(
            id: UUID(),
            timestamp: loggedDate,
            mealType: targetMealType,
            items: itemsToLog,
            notes: notes ?? plannedMeal.notes,
            imagePath: nil
        )

        // 4. Save to actual MealRepository (Meal Diary)
        // If this throws an error, the planned meal remains untouched in its prior state!
        try await mealRepository.saveMeal(mealRecord)

        // 5. Only after successful diary persistence, update the planned meal status to .completed
        try await mealPlanRepository.markMealCompleted(id: plannedMeal.id, linkedDiaryRecordId: mealRecord.id)

        return mealRecord
    }
}
