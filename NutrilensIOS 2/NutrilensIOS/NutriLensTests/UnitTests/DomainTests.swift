//
//  DomainTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//

import XCTest
@testable import NutriLens

final class DomainTests: XCTestCase {

    func testFoodItemScaling() {
        let base = FoodItem(
            name: "Test Dish",
            vietnameseName: "Món Thử Nghiệm",
            confidence: 0.95,
            servingSizeGrams: 200,
            calories: 300,
            proteinGrams: 20,
            carbGrams: 40,
            fatGrams: 10,
            fiberGrams: 4
        )

        let scaled = base.scaled(to: 400)
        XCTAssertEqual(scaled.servingSizeGrams, 400)
        XCTAssertEqual(scaled.calories, 600)
        XCTAssertEqual(scaled.proteinGrams, 40)
        XCTAssertEqual(scaled.carbGrams, 80)
        XCTAssertEqual(scaled.fatGrams, 20)
        XCTAssertEqual(scaled.fiberGrams, 8)
    }

    func testMealRecordMacronutrientAggregation() {
        let item1 = FoodItem(
            name: "Item 1",
            vietnameseName: "Món 1",
            confidence: 0.9,
            servingSizeGrams: 100,
            calories: 200,
            proteinGrams: 15,
            carbGrams: 20,
            fatGrams: 5,
            fiberGrams: 2
        )
        let item2 = FoodItem(
            name: "Item 2",
            vietnameseName: "Món 2",
            confidence: 0.9,
            servingSizeGrams: 100,
            calories: 300,
            proteinGrams: 10,
            carbGrams: 40,
            fatGrams: 8,
            fiberGrams: 3
        )

        let meal = MealRecord(
            mealType: .lunch,
            items: [item1, item2]
        )

        XCTAssertEqual(meal.totalCalories, 500)
        XCTAssertEqual(meal.totalProteinGrams, 25)
        XCTAssertEqual(meal.totalCarbGrams, 60)
        XCTAssertEqual(meal.totalFatGrams, 13)
        XCTAssertEqual(meal.totalFiberGrams, 5)
    }

    func testNutritionSummaryProgress() {
        let summary = NutritionSummary(
            consumedCalories: 1500,
            targetCalories: 2000
        )
        XCTAssertEqual(summary.calorieProgress, 0.75, accuracy: 0.001)
        XCTAssertEqual(summary.remainingCalories, 500)
    }

    func testLogMealUseCaseValidation() async {
        let repo = MockMealRepository(initialMeals: [])
        let useCase = LogMealUseCase(mealRepository: repo)

        let emptyMeal = MealRecord(mealType: .breakfast, items: [])
        do {
            try await useCase.execute(meal: emptyMeal)
            XCTFail("Should have thrown error for empty items")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.invalidInput("A meal record must contain at least one food item."))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testRecognizeFoodUseCaseOODHandling() async {
        let mockRepo = MockFoodRecognitionRepository(shouldSimulateOOD: true, simulatedDelaySeconds: 0)
        let useCase = RecognizeFoodUseCase(repository: mockRepo)

        let dummyPayload = Data("test".utf8)
        do {
            _ = try await useCase.execute(imageData: dummyPayload)
            XCTFail("Should have thrown outOfDistribution error")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.outOfDistribution)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
