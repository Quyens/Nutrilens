//
//  BarcodeScannerTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Comprehensive automated unit test suite for Phase 06 Barcode Scanner & Packaged Foods.
//

import XCTest
@testable import NutriLens

final class BarcodeScannerTests: XCTestCase {

    private var mockRepo: MockPackagedFoodRepository!
    private var lookupUseCase: LookupBarcodeUseCase!
    private var saveUseCase: SavePackagedFoodUseCase!
    private var deleteUseCase: DeletePackagedFoodUseCase!
    private var getFoodsUseCase: GetPackagedFoodsUseCase!
    private var logDiaryUseCase: LogPackagedFoodToDiaryUseCase!
    private var mockMealRepo: MockMealRepository!
    private var safetyService: PackagedFoodSafetyService!

    override func setUp() async throws {
        try await super.setUp()
        mockRepo = MockPackagedFoodRepository()
        lookupUseCase = LookupBarcodeUseCase(repository: mockRepo)
        saveUseCase = SavePackagedFoodUseCase(repository: mockRepo)
        deleteUseCase = DeletePackagedFoodUseCase(repository: mockRepo)
        getFoodsUseCase = GetPackagedFoodsUseCase(repository: mockRepo)
        mockMealRepo = MockMealRepository(initialMeals: [])
        logDiaryUseCase = LogPackagedFoodToDiaryUseCase(mealRepository: mockMealRepo)
        safetyService = PackagedFoodSafetyService()
    }

    override func tearDown() async throws {
        mockRepo = nil
        lookupUseCase = nil
        saveUseCase = nil
        deleteUseCase = nil
        getFoodsUseCase = nil
        mockMealRepo = nil
        logDiaryUseCase = nil
        safetyService = nil
        try await super.tearDown()
    }

    // MARK: - 1. Barcode Type Inference
    func testBarcodeTypeInference() {
        let ean13 = BarcodeValue(rawValue: "8934673105051")
        XCTAssertEqual(ean13.type, .ean13)

        let ean8 = BarcodeValue(rawValue: "96385074")
        XCTAssertEqual(ean8.type, .ean8)

        let upcA = BarcodeValue(rawValue: "012345678905")
        XCTAssertEqual(upcA.type, .upcA)

        let code128 = BarcodeValue(rawValue: "NUTRI-2026-LENS")
        XCTAssertEqual(code128.type, .code128)
    }

    // MARK: - 2. EAN and UPC Normalization
    func testEANAndUPCNormalization() {
        // UPC-A 12 digits: 012345678905 -> normalized to 13 digits with leading zero: 0012345678905
        let upcA = BarcodeValue(rawValue: "012345678905")
        XCTAssertEqual(upcA.type, .upcA)
        XCTAssertEqual(upcA.normalizedValue, "0012345678905")
        XCTAssertEqual(upcA.normalizedValue.count, 13)

        // EAN-13 remains 13 digits
        let ean13 = BarcodeValue(rawValue: "8934673105057")
        XCTAssertEqual(ean13.normalizedValue, "8934673105057")
    }

    // MARK: - 3. Barcode Validation (Valid Codes)
    func testBarcodeValidation_ValidCodes() {
        // Verified Vinamilk EAN-13
        let vinamilk = BarcodeValue(rawValue: "8934673105057")
        XCTAssertTrue(vinamilk.isValid)
        XCTAssertNil(vinamilk.validationError)

        // Verified Hảo Hảo EAN-13
        let haohao = BarcodeValue(rawValue: "8934563138165")
        XCTAssertTrue(haohao.isValid)
        XCTAssertNil(haohao.validationError)

        // Verified EAN-8
        let validEAN8 = BarcodeValue(rawValue: "96385074")
        XCTAssertTrue(validEAN8.isValid)
        XCTAssertNil(validEAN8.validationError)
    }

    // MARK: - 4. Invalid Barcode Handling
    func testBarcodeValidation_InvalidCodes() {
        // Corrupted check digit (check digit 1 instead of 7)
        let invalidCheck = BarcodeValue(rawValue: "8934673105051")
        XCTAssertFalse(invalidCheck.isValid)
        XCTAssertNotNil(invalidCheck.validationError)

        // Empty barcode
        let empty = BarcodeValue(rawValue: "   ")
        XCTAssertFalse(empty.isValid)
        XCTAssertEqual(empty.validationError, "Mã vạch không được để trống")

        // Too short numeric code
        let tooShort = BarcodeValue(rawValue: "12345")
        XCTAssertEqual(tooShort.type, .code128)
        XCTAssertTrue(tooShort.isValid) // Code 128 accepts 3-48 chars

        let oneChar = BarcodeValue(rawValue: "1")
        XCTAssertFalse(oneChar.isValid)
    }

    // MARK: - 5. Product Lookup (Bundled Catalogue)
    func testProductLookup_BundledCatalogue() async throws {
        let result = try await lookupUseCase.execute(barcode: "8934673105057")

        guard case let .found(food, source) = result else {
            XCTFail("Expected .found for Vinamilk barcode")
            return
        }

        XCTAssertEqual(source, .bundledCatalogue)
        XCTAssertEqual(food.brand, "Vinamilk")
        XCTAssertTrue(food.productName.contains("Sữa tươi"))
        XCTAssertEqual(food.nutrition.calories, 132)
        XCTAssertEqual(food.allergens, [.milk])
    }

    // MARK: - 6. Unknown Barcode Handling
    func testProductLookup_UnknownBarcode() async throws {
        // Valid EAN-13 check digit for unknown test code: 8939999888880
        // Let's compute a valid 13-digit code
        // 893000000001 + check digit
        // 8*1 + 9*3 + 3*1 + 0*3 + 0*1 + 0*3 + 0*1 + 0*3 + 0*1 + 0*3 + 0*1 + 1*3 = 8 + 27 + 3 + 3 = 41 -> check = 9 -> 8930000000019
        let unknownValidBarcode = "8930000000019"
        let result = try await lookupUseCase.execute(barcode: unknownValidBarcode)

        guard case let .notFound(barcodeVal) = result else {
            XCTFail("Expected .notFound for unregistered barcode")
            return
        }

        XCTAssertEqual(barcodeVal.normalizedValue, unknownValidBarcode)
    }

    // MARK: - 7. Saved Product Lookup Priority
    func testSavedProductLookupPriority() async throws {
        // Create user override with same barcode as Vinamilk (8934673105057)
        let customOverride = PackagedFood(
            barcode: "8934673105057",
            rawBarcode: "8934673105057",
            barcodeType: .ean13,
            productName: "Sữa tươi Vinamilk (Phiên bản ít đường cá nhân)",
            brand: "Vinamilk",
            serving: PackagedFoodServing(servingSize: 180, servingUnit: "ml"),
            nutrition: PackagedFoodNutrition(calories: 100, proteinGrams: 5.5, carbGrams: 10.0, fatGrams: 4.0)
        )

        // Save into user repository
        try await saveUseCase.execute(customOverride)

        // Lookup must now return userLibrary, NOT bundledCatalogue
        let result = try await lookupUseCase.execute(barcode: "8934673105057")

        guard case let .found(foundFood, source) = result else {
            XCTFail("Expected .found for overridden barcode")
            return
        }

        XCTAssertEqual(source, .userLibrary)
        XCTAssertEqual(foundFood.productName, "Sữa tươi Vinamilk (Phiên bản ít đường cá nhân)")
        XCTAssertEqual(foundFood.nutrition.calories, 100)
    }

    // MARK: - 8. Product Creation
    func testProductCreation() async throws {
        let newFood = PackagedFood(
            barcode: "8938501234018",
            rawBarcode: "8938501234018",
            barcodeType: .ean13,
            productName: "Hạt Điều Rang Muối Bazan",
            brand: "Bazan",
            category: "Hạt & Đồ ăn vặt dinh dưỡng",
            serving: PackagedFoodServing(servingSize: 30, servingUnit: "g"),
            nutrition: PackagedFoodNutrition(calories: 175, proteinGrams: 5.5, carbGrams: 8.0, fatGrams: 14.0)
        )

        try await saveUseCase.execute(newFood)

        let all = try await getFoodsUseCase.executeAll()
        XCTAssertTrue(all.contains(where: { $0.barcode == "8938501234018" }))
    }

    // MARK: - 9. Product Editing
    func testProductEditing() async throws {
        let food = PackagedFood(
            barcode: "8934563138165",
            rawBarcode: "8934563138165",
            barcodeType: .ean13,
            productName: "Mì Hảo Hảo",
            brand: "Acecook",
            nutrition: PackagedFoodNutrition(calories: 350)
        )
        try await saveUseCase.execute(food)

        // Edit
        var edited = food
        edited.productName = "Mì Hảo Hảo Tôm Chua Cay (Đã nêm thêm)"
        edited.nutrition.calories = 380
        try await saveUseCase.execute(edited)

        let fetched = try await mockRepo.fetchByBarcode(barcode: "8934563138165")
        XCTAssertEqual(fetched?.productName, "Mì Hảo Hảo Tôm Chua Cay (Đã nêm thêm)")
        XCTAssertEqual(fetched?.nutrition.calories, 380)
    }

    // MARK: - 10. Product Deletion
    func testProductDeletion() async throws {
        let food = PackagedFood(
            barcode: "8938501234018",
            productName: "Sản phẩm tạm"
        )
        try await saveUseCase.execute(food)
        var all = try await getFoodsUseCase.executeAll()
        XCTAssertEqual(all.count, 1)

        try await deleteUseCase.execute(id: food.id)
        all = try await getFoodsUseCase.executeAll()
        XCTAssertEqual(all.count, 0)
    }

    // MARK: - 11. Duplicate Barcode Handling
    func testDuplicateBarcodeHandling() async throws {
        let food1 = PackagedFood(
            id: UUID(),
            barcode: "8934673620024",
            productName: "Sữa chua Vinamilk"
        )
        try await saveUseCase.execute(food1)

        // Save another object with same barcode
        let food2 = PackagedFood(
            id: UUID(),
            barcode: "8934673620024",
            productName: "Sữa chua Vinamilk (Cập nhật)"
        )
        try await saveUseCase.execute(food2)

        let all = try await getFoodsUseCase.executeAll()
        // Must update existing barcode in place, not duplicate
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.productName, "Sữa chua Vinamilk (Cập nhật)")
    }

    // MARK: - 12. Nutrition Serving Calculations
    func testNutritionServingCalculations() {
        let base = PackagedFoodNutrition(
            calories: 100,
            proteinGrams: 5.0,
            carbGrams: 10.0,
            fatGrams: 4.0,
            fiberGrams: 2.0
        )

        let scaled = base.scaled(by: 2.5)
        XCTAssertEqual(scaled.calories, 250)
        XCTAssertEqual(scaled.proteinGrams, 12.5)
        XCTAssertEqual(scaled.carbGrams, 25.0)
        XCTAssertEqual(scaled.fatGrams, 10.0)
        XCTAssertEqual(scaled.fiberGrams, 5.0)
    }

    // MARK: - 13. Missing Nutrient Information (Preserves Nil)
    func testMissingNutrientInformation_PreservesNil() {
        let nutritionWithNil = PackagedFoodNutrition(
            calories: 100,
            proteinGrams: 2.0,
            carbGrams: 15.0,
            fatGrams: 1.0,
            fiberGrams: nil,
            calciumMg: nil,
            ironMg: nil
        )

        let scaled = nutritionWithNil.scaled(by: 1.5)
        // Critical requirement: optional nutrients must preserve nil, never convert to 0
        XCTAssertNil(scaled.fiberGrams)
        XCTAssertNil(scaled.calciumMg)
        XCTAssertNil(scaled.ironMg)
    }

    // MARK: - 14. Allergen Warning Handling (Direct Conflict)
    func testAllergenWarningHandling_DirectMatch() {
        let milkFood = BundledPackagedFoodCatalogue.shared.items.first(where: { $0.allergens.contains(.milk) })!

        var userProfile = UserDietaryProfile()
        userProfile.declaredAllergens = [.milk]

        let evaluation = safetyService.evaluate(food: milkFood, userProfile: userProfile)

        XCTAssertTrue(evaluation.hasConflicts)
        XCTAssertEqual(evaluation.conflicts.count, 1)
        XCTAssertEqual(evaluation.conflicts.first?.allergen, .milk)
    }

    // MARK: - 15. Allergen Warning Handling (Dietary Preference / Vegetarian)
    func testAllergenWarningHandling_DietaryPreference() {
        let haoHao = BundledPackagedFoodCatalogue.shared.items.first(where: { $0.allergens.contains(.shellfish) })!

        var userProfile = UserDietaryProfile()
        userProfile.dietaryPreferences = [.vegetarian]

        let evaluation = safetyService.evaluate(food: haoHao, userProfile: userProfile)

        XCTAssertTrue(evaluation.hasConflicts)
        XCTAssertTrue(evaluation.conflicts.contains(where: { $0.allergen == .shellfish || $0.allergen == .fish }))
    }

    // MARK: - 16. Allergen Warning Handling (Incomplete Data Warning)
    func testAllergenWarningHandling_IncompleteData() {
        let unverifiedFood = PackagedFood(
            barcode: "8930000000019",
            productName: "Bánh tráng trộn",
            ingredients: [],
            verificationStatus: .unverified
        )

        let userProfile = UserDietaryProfile()
        let evaluation = safetyService.evaluate(food: unverifiedFood, userProfile: userProfile)

        XCTAssertTrue(evaluation.hasIncompleteData)
    }

    // MARK: - 17. Meal Diary Integration
    func testMealDiaryIntegration() async throws {
        let vinamilk = BundledPackagedFoodCatalogue.shared.items.first!

        let loggedMeal = try await logDiaryUseCase.execute(
            packagedFood: vinamilk,
            portionMultiplier: 1.5,
            mealType: .breakfast
        )

        XCTAssertEqual(loggedMeal.mealType, .breakfast)
        XCTAssertEqual(loggedMeal.items.count, 1)

        let item = loggedMeal.items.first!
        XCTAssertEqual(item.name, vinamilk.fullDisplayTitle)
        XCTAssertEqual(item.calories, (vinamilk.nutrition.calories * 1.5).rounded())

        // Verify persisted in MealRepository
        let allMeals = try await mockMealRepo.fetchMeals(from: Date().addingTimeInterval(-3600), to: Date().addingTimeInterval(3600))
        XCTAssertEqual(allMeals.count, 1)
    }

    // MARK: - 18. Snapshot Independence
    func testSnapshotIndependence() async throws {
        var food = PackagedFood(
            barcode: "8934673105057",
            productName: "Sữa Vinamilk Ban Đầu",
            nutrition: PackagedFoodNutrition(calories: 120)
        )
        try await saveUseCase.execute(food)

        // Log to diary
        let loggedMeal = try await logDiaryUseCase.execute(packagedFood: food, portionMultiplier: 1.0)
        XCTAssertEqual(loggedMeal.items.first?.calories, 120)

        // Mutate the original packaged food afterwards
        food.productName = "Sữa Vinamilk Đã Đổi Tên"
        food.nutrition.calories = 300
        try await saveUseCase.execute(food)

        // The previously logged meal record must remain unchanged!
        let allMeals = try await mockMealRepo.fetchMeals(from: Date().addingTimeInterval(-3600), to: Date().addingTimeInterval(3600))
        XCTAssertEqual(allMeals.first?.items.first?.name, "Sữa Vinamilk Ban Đầu")
        XCTAssertEqual(allMeals.first?.items.first?.calories, 120)
    }

    // MARK: - 19. Camera Permission Handling
    @MainActor
    func testCameraPermissionHandling() {
        let mockCapture = MockBarcodeCaptureService(permissionState: .authorized)
        XCTAssertEqual(mockCapture.permissionState, .authorized)

        mockCapture.permissionState = .denied
        XCTAssertEqual(mockCapture.permissionState, .denied)

        mockCapture.permissionState = .unavailable
        XCTAssertEqual(mockCapture.permissionState, .unavailable)
    }
}
