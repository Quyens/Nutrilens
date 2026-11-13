//
//  LogPackagedFoodToDiaryUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Logs a packaged food into Meal Diary as an immutable FoodItem snapshot.
//

import Foundation

public final class LogPackagedFoodToDiaryUseCase: Sendable {
    private let mealRepository: MealRepositoryProtocol

    public init(mealRepository: MealRepositoryProtocol) {
        self.mealRepository = mealRepository
    }

    public func execute(
        packagedFood: PackagedFood,
        portionMultiplier: Double = 1.0,
        mealType: MealType = .snack,
        timestamp: Date = Date(),
        notes: String? = nil
    ) async throws -> MealRecord {
        let foodItem = packagedFood.toFoodItem(portionMultiplier: portionMultiplier)
        let meal = MealRecord(
            timestamp: timestamp,
            mealType: mealType,
            items: [foodItem],
            notes: notes ?? "Được quét từ mã vạch \(packagedFood.barcode)"
        )
        try await mealRepository.saveMeal(meal)
        return meal
    }
}

