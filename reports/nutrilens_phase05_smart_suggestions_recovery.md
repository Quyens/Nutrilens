# NutriLens V1.0 — Phase 05 Recovery Report
## Smart Meal Suggestions — Personalized, Explainable & Offline-First Recommendations

**Status:** Completed & Fully Verified  
**Date:** November 11, 2026  
**Auditor / Architect:** Principal iOS Engineer, Recommendation Systems Engineer & Senior QA Architect  
**Target Environment:** iOS 17.0+ Simulator (iPhone 17)  
**Test Baseline Result:** 129 Tests Passing (120 Unit Tests + 9 UI Tests) • 0 Regressions • 100% Pass Rate  

---

## 1. Executive Summary

Phase 05 of **NutriLens V1.0** delivers an offline-first, personalized, explainable **Smart Meal Suggestions ("Gợi ý món ăn thông minh")** recommendation system. The module is architected strictly under Clean Architecture and MVVM principles, featuring a deterministic, transparent, rule-based recommendation engine (`SmartMealSuggestionEngine`). It processes candidate dishes from the 35+ Vietnamese National Database, user-created Custom Foods (Phase 03), and Custom Recipes (Phase 03), evaluates dietary preferences, eliminates declared allergen risks, ensures meal variety across the week, provides human-readable explanations ("Điểm phù hợp: 88/100"), and bridges recommendations seamlessly into the Weekly Meal Planner (Phase 04).

### Key Milestones Achieved
1. **Domain Layer:** Built [`AllergenType`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/AllergenType.swift), [`DietaryPreferenceType`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/DietaryPreferenceType.swift), [`UserDietaryProfile`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/UserDietaryProfile.swift), [`IngredientVerificationStatus`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/IngredientVerificationStatus.swift), [`MealSuggestion`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/MealSuggestion.swift), and [`SmartSuggestionsFilter`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/SmartSuggestionsFilter.swift).
2. **Deterministic Recommendation Engine:** Implemented [`SmartMealSuggestionEngine`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Services/SmartMealSuggestionEngine.swift) featuring documented scoring weights, category matching, personal favorites boost, dietary lifestyle alignment (High Protein, Low-Carb, Vegetarian, Pescatarian, Eat Clean), variety scoring, and recency penalties.
3. **Allergen & Ingredient Safety:** Built [`VietnameseDishIngredientMetadata`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Services/VietnameseDishIngredientMetadata.swift) mapping all 35 dishes to documented ingredients and common allergens according to the National Institute of Nutrition (NIN) Vietnam and USDA guidelines. Disliked ingredients and declared allergen conflicts are strictly excluded or clearly flagged. Missing ingredient metadata is conservatively categorized as `.partial` or `.unverified` ("Chưa đủ thông tin thành phần"), avoiding false claims of laboratory certification.
4. **Local Persistence:** Created [`UserDietaryProfileRepository`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/Repositories/UserDietaryProfileRepository.swift) and [`MockUserDietaryProfileRepository`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/Repositories/MockUserDietaryProfileRepository.swift), preserving user dietary preferences, allergens, and disliked ingredients across app restarts.
5. **Use Case Layer:** Built [`SmartMealSuggestionsUseCase`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/UseCases/SmartMealSuggestionsUseCase.swift), coordinating candidates from repositories, running the deterministic engine, handling favorites toggling, and scaling portions for atomic addition to the Weekly Meal Planner.
6. **Fresh Premium Botanical UI:** Designed and built:
   - [`SmartSuggestionsView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/SmartSuggestionsView.swift) (Dynamic Island clearance, search, category pills, dietary style pills, empty and loading states).
   - [`SuggestionCardView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/SuggestionCardView.swift) (Card geometry, source pill, match badge, macro chips, action buttons).
   - [`RecommendationExplanationSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/RecommendationExplanationSheet.swift) ("Tại sao gợi ý món này?").
   - [`IngredientReviewSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/IngredientReviewSheet.swift) ("Thành phần & Dị ứng", status badge, cross-contact disclosure).
   - [`EditDietaryPreferencesSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/EditDietaryPreferencesSheet.swift) (Lifestyles, declared allergens, disliked ingredient tags).
   - [`AddSuggestionToPlanSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/AddSuggestionToPlanSheet.swift) (Portion slider, live macro calculation, Weekly Planner integration).
7. **Cross-Module Navigation Integration:** Integrated entry points in Home Dashboard, Food Explorer, Weekly Meal Planner (empty meal sections), and Profile without altering the native 5-tab bar structure.
8. **Automated Test Suite Expansion:** Added 16 new unit tests in [`SmartSuggestionsTests.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLensTests/UnitTests/SmartSuggestionsTests.swift) and UI test `testSmartSuggestionsFlow` in [`NutriLensUITests.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLensUITests/NutriLensUITests.swift). All 129 automated tests passed with 100% pass rate.

---

## 2. Recommendation Algorithm & Scoring Architecture

```
                                  +------------------------------------+
                                  |     SmartSuggestionsFilter         |
                                  | (Category, Dietary Style, Search)  |
                                  +------------------------------------+
                                                     |
+--------------------------+                         v                         +--------------------------+
| VietnameseNutritionDB    | ----> +-----------------------------------+ <---- | UserDietaryProfile       |
| (35+ NIN Dishes)         |       |                                   |       | (Allergens, Dislikes)    |
+--------------------------+       |                                   |       +--------------------------+
| CustomFoodRepository     | ----> |    SmartMealSuggestionEngine      | <---- | MealRepository (Diary)   |
| (Phase 03 Saved Foods)   |       |   (Deterministic Rule-Based)      |       | (Recency & Frequency)    |
+--------------------------+       |                                   |       +--------------------------+
| RecipeRepository         | ----> |                                   | <---- | MealPlanRepository       |
| (Phase 03 User Recipes)  |       +-----------------------------------+       | (Weekly Variety)         |
+--------------------------+                         |                         +--------------------------+
                                                     v
                                      [MealSuggestion] (Ranked)
                                      • recommendationScore (0-100)
                                      • explanationFactors
                                      • ingredientVerificationStatus
                                      • allergenWarnings
```

### Deterministic Scoring Weights (Base: 50 pts)
1. **Target Meal Category Fit (+25 pts):**
   - Breakfast: Phở, Bánh mì, Bánh cuốn, Xôi, Hủ tiếu, Bánh giò, Bánh canh, Cháo lòng, Bò kho...
   - Lunch: Cơm tấm, Bún bò Huế, Bún chả, Cơm gà, Bún riêu, Bún thịt nướng, Canh chua, Bánh xèo...
   - Dinner: Cá kho tộ, Canh chua, Bò kho, Cơm tấm, Bánh cuốn, Phở...
   - Snack: Chè đậu đỏ, Bánh bèo, Bánh bột lọc, Bánh căn, Bánh tráng nướng, Nem chua, Bánh pía...
   - When a user explicitly filters by a meal category (e.g. "Bữa sáng"), unsuitable dishes are cleanly excluded.
2. **User Favorite Boost (+20 pts):**
   - Active favorite in `FoodFavoritesRepositoryProtocol` or `CustomFood`/`Recipe.isFavorite == true`.
   - Reason tag: *"Món bạn yêu thích"*.
3. **Dietary Preference Alignment (+12 to +20 pts):**
   - High Protein (Protein >= 25g): +20 pts (*"Hàm lượng đạm cao (32g Protein)"*).
   - Low Carb (Carb <= 25g): +18 pts (*"Lượng tinh bột thấp (18g Carb)"*).
   - Balanced: +15 pts (*"Cân đối đa lượng NIN"*).
   - Eat Clean: +15 pts (*"Thanh đạm & giàu chất xơ"*).
   - Traditional Vietnamese: +12 pts (*"Đặc sản món Việt chuẩn vị"*).
4. **User Custom Food & Recipe Boost (+15 pts):**
   - Custom Food: +15 pts (*"Món ăn từ thư viện cá nhân của bạn"*).
   - Recipe: +15 pts (*"Công thức do bạn tự sáng tạo"*).
5. **Weekly Variety & Recency Scoring (-25 to +10 pts):**
   - Logged in Meal Diary today or scheduled in Planner today: -25 pts (*"Đã có trong thực đơn hôm nay — ưu tiên món khác để đổi vị"*).
   - Unconsumed recently: +10 pts (*"Giúp đổi vị & đa dạng thực đơn"*).
6. **Safety Disqualification (Hard Filter):**
   - Declared allergen conflict: Excluded when `excludeKnownAllergens == true`.
   - Disliked ingredients: Excluded if dish name or documented ingredients match user's dislike list.
   - Vegetarian diet: Meat and poultry dishes are strictly eliminated.
7. **Tie-Breaking:**
   - Sorted by `recommendationScore` descending, then by `displayName` ascending for absolute determinism.

---

## 3. Allergen & Ingredient Safety Policy

1. **Documented Data Integrity:**
   - Ingredients and potential allergens are mapped in [`VietnameseDishIngredientMetadata`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Services/VietnameseDishIngredientMetadata.swift) based on published recipes from the National Institute of Nutrition (NIN) Vietnam.
   - Unknown dishes or custom foods without ingredient lists are categorized as `.partial` or `.unverified` ("Chưa đủ thông tin thành phần"), never certified as safe.
2. **Zero False Claims of Laboratory Certification:**
   - The UI and disclaimers explicitly inform the user: *"Dữ liệu đối chiếu theo Bảng Thành phần Thực phẩm Việt Nam (NIN) và USDA FoodData Central. Không thay thế kiểm nghiệm thực tế tại cơ sở chế biến."*
3. **Cross-Contact & Preparation Notice:**
   - In [`IngredientReviewSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/SmartSuggestions/IngredientReviewSheet.swift), a permanent alert notes: *"Nước xốt, dầu chiên, gia vị nêm hoặc nguy cơ nhiễm chéo trong gian bếp có thể chứa chất gây dị ứng. Người có cơ địa dị ứng nguy cấp cần luôn xác thực với nhà hàng."*

---

## 4. Visual Simulator Evidence (iPhone 17, iOS 26.5)

All 5 required high-resolution screenshots captured and verified:

| # | Screenshot Name | Description | Local File Link |
|---|---|---|---|
| 1 | `1_smart_suggestions_overview.png` | Smart suggestions main overview with category pills, active dietary style filters, and suggestion cards | [`1_smart_suggestions_overview.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase05/1_smart_suggestions_overview.png) |
| 2 | `2_recommendation_explanation.png` | Transparent explanation sheet ("Tại sao gợi ý món này?"), positive scoring factors breakdown, and algorithm disclosure | [`2_recommendation_explanation.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase05/2_recommendation_explanation.png) |
| 3 | `3_ingredient_review.png` | Ingredient review sheet with verification status badge, potential allergen analysis, and cross-contact disclaimer | [`3_ingredient_review.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase05/3_ingredient_review.png) |
| 4 | `4_dietary_preferences.png` | Dietary preferences editor with lifestyles, declared allergen multi-select, and disliked ingredient tag field | [`4_dietary_preferences.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase05/4_dietary_preferences.png) |
| 5 | `5_add_to_weekly_planner.png` | Bridge modal to Weekly Meal Planner with date picker, category tabs, portion slider, and live nutrition preview | [`5_add_to_weekly_planner.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase05/5_add_to_weekly_planner.png) |

---

## 5. Automated Test Suite Metrics

```
Executed 120 Unit Tests, with 0 failures (0 unexpected) in 0.945 seconds
Executed 9 UI Tests, with 0 failures (0 unexpected) in 243.534 seconds
Total: 129 Tests Passing • 0 Regressions • 100% Pass Rate
```

### Verified Test Cases in `SmartSuggestionsTests.swift`
1. `testDeterministicRecommendationRanking`: Verified identical ordering and scores across repeated executions.
2. `testMealCategoryFiltering`: Verified breakfast filter surfaces authentic Vietnamese breakfast dishes.
3. `testHighProteinPreferenceMatching`: Verified high protein preference boosts dishes with 25g+ protein.
4. `testFavoritePrioritization`: Verified user favorites receive +20 pts and the favorite reason tag.
5. `testRecentMealDiversityPenalty`: Verified dishes consumed today receive a -25 pt variety penalty.
6. `testKnownAllergenConflictExclusion`: Verified declared shellfish allergy strictly excludes dishes containing shellfish/ruốc.
7. `testMissingIngredientUncertainty`: Verified custom foods without ingredients are labeled as `.partial` ("Thành phần chưa đầy đủ").
8. `testCustomFoodIntegration`: Verified user custom foods are included and scored properly.
9. `testRecipeIntegration`: Verified multi-ingredient recipes from Phase 03 are integrated with scaled nutrition.
10. `testAddSuggestionToWeeklyPlan`: Verified adding a suggestion saves a valid `PlannedMeal` into `MealPlanRepository`.
11. `testPortionMultiplierScaling`: Verified portion multiplier (1.5x) scales calories and macros accurately.
12. `testPreferencePersistence`: Verified save, load, and clear operations of `UserDietaryProfile`.
13. `testEmptyRecommendationResults`: Verified non-matching search queries return an empty list gracefully.
14. `testOfflineOperationWithoutNetwork`: Verified the entire recommendation pipeline operates without network requests.
15. `testAddDuplicateDishToPlannedMeal`: Verified adding duplicate dish appends to existing planned meal.
16. `testVegetarianExcludesMeatDishes`: Verified vegetarian preference excludes Phở bò, Cơm tấm, and Bún chả.

---

## 6. Files Created and Modified

### Created Files (16 New Files)
- **Domain Layer:**
  - `NutriLens/Domain/Entities/AllergenType.swift`
  - `NutriLens/Domain/Entities/DietaryPreferenceType.swift`
  - `NutriLens/Domain/Entities/UserDietaryProfile.swift`
  - `NutriLens/Domain/Entities/IngredientVerificationStatus.swift`
  - `NutriLens/Domain/Entities/MealSuggestion.swift`
  - `NutriLens/Domain/Entities/SmartSuggestionsFilter.swift`
  - `NutriLens/Domain/RepositoryInterfaces/UserDietaryProfileRepositoryProtocol.swift`
  - `NutriLens/Domain/Services/VietnameseDishIngredientMetadata.swift`
  - `NutriLens/Domain/Services/SmartMealSuggestionEngine.swift`
  - `NutriLens/Domain/UseCases/SmartMealSuggestionsUseCase.swift`
- **Data Layer:**
  - `NutriLens/Data/Repositories/UserDietaryProfileRepository.swift`
  - `NutriLens/Data/Repositories/MockUserDietaryProfileRepository.swift`
- **Presentation Layer:**
  - `NutriLens/Features/SmartSuggestions/SmartSuggestionsViewModel.swift`
  - `NutriLens/Features/SmartSuggestions/SuggestionCardView.swift`
  - `NutriLens/Features/SmartSuggestions/RecommendationExplanationSheet.swift`
  - `NutriLens/Features/SmartSuggestions/IngredientReviewSheet.swift`
  - `NutriLens/Features/SmartSuggestions/EditDietaryPreferencesSheet.swift`
  - `NutriLens/Features/SmartSuggestions/AddSuggestionToPlanSheet.swift`
  - `NutriLens/Features/SmartSuggestions/SmartSuggestionsView.swift`
- **Automated Tests:**
  - `NutriLensTests/UnitTests/SmartSuggestionsTests.swift`

### Modified Files (6 Files)
- `NutriLens/Domain/Entities/PlannedFoodItem.swift` (added `systemIcon` to `PlannedFoodSourceType`)
- `NutriLens/App/AppEnvironment.swift` (injected dietary repo and use case; added factory method)
- `NutriLens/App/AppRouter.swift` (added modal sheets and launch arguments)
- `NutriLens/Features/Home/HomeView.swift` (added `SmartSuggestionsHomeBanner` entry point)
- `NutriLens/Features/FoodExplorer/FoodExplorerView.swift` (added `smartSuggestionsShortcutBanner` entry point)
- `NutriLens/Features/WeeklyMealPlanner/WeeklyMealPlannerView.swift` (added "Gợi ý" button to empty meal sections)
- `NutriLens/Features/Profile/ProfileView.swift` (connected `PreferencesView` to `UserDietaryProfileRepository`)
- `NutriLensUITests/NutriLensUITests.swift` (added `testSmartSuggestionsFlow`)

---

## 7. Known Limitations & Phase 06 Readiness Assessment

### Scope Boundaries Maintained
- **Smart Grocery List:** Automated grocery list aggregation from planned meals and recipes is deferred to Phase 06.
- **Micro-Target Auto-Balancing:** Automated daily caloric deficit bridging will be integrated with the grocery module in Phase 06.
- **Zero Cloud Leakage:** All recommendations, scoring, and preferences remain 100% on-device and offline.

### Phase 06 Readiness: GREEN
- Architecture is cleanly decoupled, type-safe, and thoroughly tested.
- Existing SwiftData models and UserDefaults data remain completely intact.
- Strict Git policy observed: zero git write operations performed; uncommitted changes preserved locally on branch `main`.

