//
//  FoodExplorerTests.swift
//  NutriLensTests
//
//  Created for NutriLens Clean Architecture iOS App.
//  Unit tests covering Food Database & Explorer V1:
//  Taxonomy, Portion Calculation, Diacritic Search, Provenance, Favorites, and Recents.
//

import XCTest
@testable import NutriLens

final class FoodExplorerTests: XCTestCase {

    // MARK: - 1. Database Integrity & Provenance Tests
    func testAllDishesHaveValidProvenanceAndCitations() {
        let dishes = VietnameseNutritionDatabase.dishes
        XCTAssertGreaterThanOrEqual(dishes.count, 30, "Database must contain at least 30 canonical classes")

        for dish in dishes {
            XCTAssertFalse(dish.id.isEmpty, "Dish ID must not be empty")
            XCTAssertFalse(dish.slug.isEmpty, "Dish slug must not be empty")
            XCTAssertFalse(dish.vietnameseName.isEmpty, "Vietnamese name must not be empty")
            XCTAssertFalse(dish.englishName.isEmpty, "English name must not be empty")
            XCTAssertFalse(dish.category.isEmpty, "Category must not be empty")
            XCTAssertFalse(dish.provenance.isEmpty, "Provenance must be traceable")
            XCTAssertFalse(dish.referenceCode.isEmpty, "Reference code must be provided")
            XCTAssertFalse(dish.verificationMethod.isEmpty, "Verification method must be specified")
            XCTAssertFalse(dish.limitations.isEmpty, "Limitations must be disclosed")
            XCTAssertFalse(dish.summary.isEmpty, "Summary must be present")

            XCTAssertGreaterThan(dish.standardServingGrams, 0, "\(dish.id) serving grams must be positive")
            XCTAssertGreaterThan(dish.caloriesPerServing, 0, "\(dish.id) calories must be positive")
            XCTAssertGreaterThanOrEqual(dish.proteinPerServing, 0, "\(dish.id) protein must be non-negative")
            XCTAssertGreaterThanOrEqual(dish.carbPerServing, 0, "\(dish.id) carbs must be non-negative")
            XCTAssertGreaterThanOrEqual(dish.fatPerServing, 0, "\(dish.id) fat must be non-negative")
            XCTAssertGreaterThanOrEqual(dish.fiberPerServing, 0, "\(dish.id) fiber must be non-negative")
            XCTAssertFalse(dish.assetImageName.isEmpty, "\(dish.id) asset image name must not be empty")
        }
    }

    // MARK: - 2. Portion Calculator Tests
    func testPortionScalingPresets() {
        guard let pho = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "pho" }) else {
            XCTFail("Pho profile must exist")
            return
        }

        let baseServing = pho.standardServingGrams
        let baseCalories = pho.caloriesPerServing

        // Standard 1.0x
        let scaled1x = PortionCalculationService.scale(profile: pho, targetGrams: baseServing)
        XCTAssertEqual(scaled1x.servingGrams, baseServing)
        XCTAssertEqual(scaled1x.calories, baseCalories, accuracy: 1.0)
        XCTAssertEqual(scaled1x.scaleFactor, 1.0, accuracy: 0.01)

        // Half 0.5x
        let scaledHalf = PortionCalculationService.scale(profile: pho, targetGrams: baseServing * 0.5)
        XCTAssertEqual(scaledHalf.servingGrams, baseServing * 0.5)
        XCTAssertEqual(scaledHalf.calories, baseCalories * 0.5, accuracy: 1.0)
        XCTAssertEqual(scaledHalf.scaleFactor, 0.5, accuracy: 0.01)

        // Double 2.0x
        let scaledDouble = PortionCalculationService.scale(profile: pho, targetGrams: baseServing * 2.0)
        XCTAssertEqual(scaledDouble.servingGrams, baseServing * 2.0)
        XCTAssertEqual(scaledDouble.calories, baseCalories * 2.0, accuracy: 1.0)
        XCTAssertEqual(scaledDouble.scaleFactor, 2.0, accuracy: 0.01)
    }

    func testPortionSafeBoundariesClamping() {
        guard let banhMi = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "banh_mi" }) else {
            XCTFail("Banh Mi profile must exist")
            return
        }

        // Test below minimum
        let belowMin = PortionCalculationService.scale(profile: banhMi, targetGrams: 2.0)
        XCTAssertEqual(belowMin.servingGrams, PortionCalculationService.minGrams, "Should clamp to min 10g")

        // Test negative
        let negative = PortionCalculationService.scale(profile: banhMi, targetGrams: -100.0)
        XCTAssertEqual(negative.servingGrams, PortionCalculationService.minGrams, "Should clamp negative to min 10g")

        // Test above maximum
        let aboveMax = PortionCalculationService.scale(profile: banhMi, targetGrams: 9999.0)
        XCTAssertEqual(aboveMax.servingGrams, PortionCalculationService.maxGrams, "Should clamp to max 2000g")

        // Test NaN
        let nanScale = PortionCalculationService.scale(profile: banhMi, targetGrams: Double.nan)
        XCTAssertEqual(nanScale.servingGrams, PortionCalculationService.minGrams, "Should clamp NaN to min 10g")
    }

    // MARK: - 3. Category Taxonomy Tests
    func testCategoryFilterMatching() {
        let dishes = VietnameseNutritionDatabase.dishes

        // All category
        let allMatches = dishes.filter { FoodExplorerCategory.all.matches(profile: $0) }
        XCTAssertEqual(allMatches.count, dishes.count)

        // Noodle Soup
        let soups = dishes.filter { FoodExplorerCategory.noodleSoup.matches(profile: $0) }
        XCTAssertTrue(soups.contains { $0.slug.contains("pho") || $0.slug.contains("bun") || $0.category == "Món Nước" })

        // Rice
        let rice = dishes.filter { FoodExplorerCategory.rice.matches(profile: $0) }
        XCTAssertTrue(rice.contains { $0.slug.contains("com") || $0.slug.contains("xoi") })

        // Pastry
        let pastries = dishes.filter { FoodExplorerCategory.pastry.matches(profile: $0) }
        XCTAssertTrue(pastries.contains { $0.slug.contains("banh") })
    }

    // MARK: - 4. Accent-Insensitive Search Tests
    @MainActor
    func testDiacriticInsensitiveSearch() {
        let repo = MockFoodFavoritesRepository()
        let vm = FoodExplorerViewModel(favoritesRepository: repo)

        // Search "pho" (no accent) -> should match "Phở Bò Tái Nạm"
        vm.searchQuery = "pho"
        let phoResults = vm.filteredDishes
        XCTAssertTrue(phoResults.contains { $0.slug == "pho" }, "Searching 'pho' must match 'Phở Bò'")

        // Search "banh mi" -> should match "Bánh Mì Thịt Nguội"
        vm.searchQuery = "banh mi"
        let banhMiResults = vm.filteredDishes
        XCTAssertTrue(banhMiResults.contains { $0.slug == "banh_mi" }, "Searching 'banh mi' must match 'Bánh Mì'")

        // Search uppercase "BUN CHA"
        vm.searchQuery = "BUN CHA"
        let bunChaResults = vm.filteredDishes
        XCTAssertTrue(bunChaResults.contains { $0.slug == "bun_cha" }, "Searching 'BUN CHA' must match 'Bún Chả'")

        // Search canonical ID "dish_com_tam"
        vm.searchQuery = "dish_com_tam"
        let comTamResults = vm.filteredDishes
        XCTAssertTrue(comTamResults.contains { $0.id == "dish_com_tam" }, "Searching canonical ID must match")
    }

    // MARK: - 5. Favorites Storage & Toggle Tests
    @MainActor
    func testFavoritesAddRemoveAndPersistence() {
        let repo = MockFoodFavoritesRepository()
        let vm = FoodExplorerViewModel(favoritesRepository: repo)

        let testId = "dish_pho"
        XCTAssertFalse(vm.isFavorite(dishId: testId), "Should not be favorite initially")

        // Toggle on
        vm.toggleFavorite(dishId: testId)
        XCTAssertTrue(vm.isFavorite(dishId: testId), "Should be favorite after toggle")
        XCTAssertTrue(repo.isFavorite(id: testId))

        // Toggle off
        vm.toggleFavorite(dishId: testId)
        XCTAssertFalse(vm.isFavorite(dishId: testId), "Should not be favorite after second toggle")
        XCTAssertFalse(repo.isFavorite(id: testId))
    }

    // MARK: - 6. Recently Viewed Tracking Tests
    @MainActor
    func testRecentlyViewedTrackingAndOrder() {
        let repo = MockFoodFavoritesRepository()
        let vm = FoodExplorerViewModel(favoritesRepository: repo)

        guard let pho = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "pho" }),
              let banhMi = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "banh_mi" }) else {
            XCTFail("Dishes must exist")
            return
        }

        // Open Pho
        vm.openDishDetail(dish: pho)
        XCTAssertEqual(vm.recentlyViewedDishes.first?.id, pho.id)

        // Open Banh Mi
        vm.openDishDetail(dish: banhMi)
        XCTAssertEqual(vm.recentlyViewedDishes.first?.id, banhMi.id, "Most recently opened should be first")
        XCTAssertEqual(vm.recentlyViewedDishes.count, 2)

        // Open Pho again -> deduplicated, moved to front
        vm.openDishDetail(dish: pho)
        XCTAssertEqual(vm.recentlyViewedDishes.first?.id, pho.id, "Re-opened dish should move to front")
        XCTAssertEqual(vm.recentlyViewedDishes.count, 2, "Duplicate should not increase count")

        // Clear
        vm.clearRecentlyViewed()
        XCTAssertTrue(vm.recentlyViewedDishes.isEmpty, "Recently viewed should be empty after clear")
    }

    // MARK: - 7. Filtered Dishes Combining Category and Favorites
    @MainActor
    func testCombinedFiltering() {
        let repo = MockFoodFavoritesRepository()
        let vm = FoodExplorerViewModel(favoritesRepository: repo)

        guard let pho = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "pho" }),
              let comTam = VietnameseNutritionDatabase.dishes.first(where: { $0.slug == "com_tam" }) else {
            XCTFail("Dishes must exist")
            return
        }

        vm.toggleFavorite(dishId: pho.id)
        vm.toggleFavorite(dishId: comTam.id)

        vm.onlyFavorites = true
        XCTAssertEqual(vm.filteredDishes.count, 2)

        // Narrow down by noodle soup category
        vm.selectedCategory = .noodleSoup
        let favSoups = vm.filteredDishes
        XCTAssertTrue(favSoups.contains { $0.id == pho.id })
        XCTAssertFalse(favSoups.contains { $0.id == comTam.id })
    }
}
