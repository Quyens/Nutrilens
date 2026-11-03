//
//  RepositoryTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//

import XCTest
@testable import NutriLens

final class RepositoryTests: XCTestCase {

    func testMockMealRepositoryOperations() async throws {
        let repo = MockMealRepository(initialMeals: [])
        let testItem = FoodItem(
            name: "Com Tam",
            vietnameseName: "Cơm Tấm",
            confidence: 0.95,
            servingSizeGrams: 300,
            calories: 550,
            proteinGrams: 28,
            carbGrams: 65,
            fatGrams: 16,
            fiberGrams: 3
        )
        let meal = MealRecord(mealType: .lunch, items: [testItem])

        // Save
        try await repo.saveMeal(meal)
        var all = try await repo.fetchAllMeals()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.id, meal.id)

        // Delete
        try await repo.deleteMeal(id: meal.id)
        all = try await repo.fetchAllMeals()
        XCTAssertEqual(all.count, 0)
    }

    func testDefaultOODDetector() {
        let detector = DefaultOODDetector(minimumConfidenceThreshold: 0.50)

        // Low confidence => Out of Distribution
        XCTAssertTrue(detector.isOutOfDistribution(confidences: [0.3, 0.2, 0.1], maxConfidence: 0.3))

        // High confidence => In distribution
        XCTAssertFalse(detector.isOutOfDistribution(confidences: [0.85, 0.1], maxConfidence: 0.85))
    }
}
