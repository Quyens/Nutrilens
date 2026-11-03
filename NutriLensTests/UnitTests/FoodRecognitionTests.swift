//
//  FoodRecognitionTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Tests end-to-end Food Recognition logic, Vietnamese nutrition database,
//  and ViewModel state machine.
//

import XCTest
@testable import NutriLens

@MainActor
final class FoodRecognitionTests: XCTestCase {

    func testVietnameseNutritionDatabaseDataIntegrity() {
        let dishes = VietnameseNutritionDatabase.dishes
        XCTAssertGreaterThanOrEqual(dishes.count, 30, "Database must include all 30 canonical Vietnamese classes")

        for dish in dishes {
            XCTAssertFalse(dish.vietnameseName.isEmpty)
            XCTAssertFalse(dish.slug.isEmpty)
            XCTAssertGreaterThan(dish.standardServingGrams, 0)
            XCTAssertGreaterThan(dish.caloriesPerServing, 0)
            XCTAssertGreaterThanOrEqual(dish.proteinPerServing, 0)
            XCTAssertGreaterThanOrEqual(dish.carbPerServing, 0)
            XCTAssertGreaterThanOrEqual(dish.fatPerServing, 0)
            XCTAssertFalse(dish.provenance.isEmpty, "Provenance citation is mandatory")
            XCTAssertFalse(dish.referenceCode.isEmpty, "Reference code is mandatory")
        }
    }

    func testThirtyCanonicalClassesIntegrity() {
        let canonical30 = [
            "banh_beo", "banh_bot_loc", "banh_can", "banh_canh", "banh_chung",
            "banh_cuon", "banh_duc", "banh_gio", "banh_khot", "banh_mi",
            "banh_pia", "banh_tet", "banh_trang_nuong", "banh_xeo", "bun_bo_hue",
            "bun_dau_mam_tom", "bun_mam", "bun_rieu", "bun_thit_nuong", "ca_kho_to",
            "canh_chua", "cao_lau", "chao_long", "com_tam", "goi_cuon",
            "hu_tieu", "mi_quang", "nem_chua", "pho", "xoi"
        ]

        for slug in canonical30 {
            let matched = VietnameseNutritionDatabase.dish(forSlug: slug)
            XCTAssertNotNil(matched, "Canonical class '\(slug)' must exist in VietnameseNutritionDatabase")
        }
    }

    func testOODDetectorModelSpecificThresholds() {
        let validatedDetector = ValidatedEfficientNetB0OODDetector()
        XCTAssertEqual(validatedDetector.threshold, 0.70, "EfficientNet-B0 OOD threshold must be exactly 0.70 as calibrated")
        XCTAssertTrue(validatedDetector.isValidated)
        XCTAssertTrue(validatedDetector.isOutOfDistribution(confidences: [0.65], maxConfidence: 0.65))
        XCTAssertFalse(validatedDetector.isOutOfDistribution(confidences: [0.75], maxConfidence: 0.75))

        let fallbackDetector = UnvalidatedVisionFallbackOODDetector()
        XCTAssertEqual(fallbackDetector.threshold, 0.45)
        XCTAssertFalse(fallbackDetector.isValidated, "Vision fallback detector must be explicitly flagged as unvalidated")
    }

    func testVietnameseNutritionDatabaseSearch() {
        let phoResults = VietnameseNutritionDatabase.search(query: "pho")
        XCTAssertFalse(phoResults.isEmpty)
        XCTAssertTrue(phoResults.contains { $0.vietnameseName.contains("Phở") })

        let comResults = VietnameseNutritionDatabase.search(query: "cơm tấm")
        XCTAssertFalse(comResults.isEmpty)
        XCTAssertTrue(comResults.contains { $0.vietnameseName.contains("Cơm Tấm") })
    }

    func testFoodRecognitionFlowStepTransitions() async throws {
        let repo = MockFoodRecognitionRepository(shouldSimulateOOD: false, simulatedDelaySeconds: 0.01)
        let recognizeUseCase = RecognizeFoodUseCase(repository: repo)
        let mealRepo = MockMealRepository(initialMeals: [])
        let logMealUseCase = LogMealUseCase(mealRepository: mealRepo)

        let viewModel = FoodRecognitionViewModel(
            recognizeFoodUseCase: recognizeUseCase,
            logMealUseCase: logMealUseCase
        )

        // 1. Initial state
        XCTAssertEqual(viewModel.currentStep, .camera)
        XCTAssertNil(viewModel.activeFoodItem)

        // 2. Select Sample Dish
        guard let phoSample = VietnameseNutritionDatabase.sampleDishes.first else {
            XCTFail("Sample dishes should not be empty")
            return
        }

        await viewModel.selectSampleDish(phoSample)

        // 3. Verify Recognition Result Step
        XCTAssertEqual(viewModel.currentStep, .recognitionResult)
        XCTAssertEqual(viewModel.activeFoodItem?.vietnameseName, phoSample.vietnameseName)
        XCTAssertFalse(viewModel.alternativeCandidates.isEmpty)

        // 4. Test Switching to Alternative Candidate
        if let alt = viewModel.alternativeCandidates.first {
            let altName = alt.item.vietnameseName
            viewModel.selectAlternativeCandidate(alt)
            XCTAssertEqual(viewModel.activeFoodItem?.vietnameseName, altName)
        }

        // 5. Transition to Nutrition Review
        viewModel.proceedToNutritionReview()
        XCTAssertEqual(viewModel.currentStep, .nutritionReview)

        // 6. Adjust Portion Size
        let initialGrams = viewModel.servingSizeGrams
        viewModel.adjustServing(delta: 50)
        XCTAssertEqual(viewModel.servingSizeGrams, initialGrams + 50)

        viewModel.setServingGrams(600)
        XCTAssertEqual(viewModel.servingSizeGrams, 600)
        XCTAssertEqual(viewModel.scaledFoodItem?.servingSizeGrams, 600)

        // 7. Select Meal Category
        viewModel.setMealType(.dinner)
        XCTAssertEqual(viewModel.selectedMealType, .dinner)

        // 8. Confirm & Save to SwiftData
        let savedMeal = try await viewModel.confirmAndSave()
        XCTAssertEqual(savedMeal.mealType, .dinner)
        XCTAssertEqual(savedMeal.items.count, 1)

        // 9. Verify Persistence in repository
        let allMeals = try await mealRepo.fetchAllMeals()
        XCTAssertEqual(allMeals.count, 1)
        XCTAssertEqual(allMeals.first?.items.first?.servingSizeGrams, 600)

        // 10. Reset returns to camera
        viewModel.reset()
        XCTAssertEqual(viewModel.currentStep, .camera)
    }

    func testOODHandlingInViewModel() async {
        let repo = MockFoodRecognitionRepository(shouldSimulateOOD: true, simulatedDelaySeconds: 0.01)
        let recognizeUseCase = RecognizeFoodUseCase(repository: repo)
        let viewModel = FoodRecognitionViewModel(recognizeFoodUseCase: recognizeUseCase)

        let fakeImageData = Data("non_food_payload".utf8)
        await viewModel.analyzeImage(data: fakeImageData)

        if case .error(let appError) = viewModel.currentStep {
            XCTAssertEqual(appError, AppError.outOfDistribution)
        } else {
            XCTFail("Expected OOD error state, got \(viewModel.currentStep)")
        }
    }

    func testCameraServiceOnSimulator() {
        let service = CameraService()
        #if targetEnvironment(simulator)
        XCTAssertFalse(service.isCameraAvailable, "Camera is unavailable on simulator")
        XCTAssertEqual(service.permissionState, .unavailable)
        #endif
    }
}
