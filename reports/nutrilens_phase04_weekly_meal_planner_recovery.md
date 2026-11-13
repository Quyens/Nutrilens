# NutriLens V1.0 — Phase 04 Recovery Report
## Weekly Meal Planner & Nutritional Schedule Management

**Status:** Completed & Fully Verified  
**Date:** November 10, 2026  
**Auditor / Architect:** Principal iOS Engineer, SwiftUI Architect & SwiftData Specialist  
**Target Environment:** iOS 17.0+ Simulator (iPhone 17)  
**Test Baseline Result:** 112 Tests Passing (104 Unit Tests + 8 UI Tests) • 0 Regressions • 100% Pass Rate  

---

## 1. Executive Summary

Phase 04 of **NutriLens V1.0** delivers a complete, offline-first **Weekly Meal Planner ("Kế hoạch thực đơn")** built strictly following Clean Architecture and MVVM principles. This system empowers users to plan 7-day nutritional schedules (Monday through Sunday), organize meals across four distinct categories (*Bữa sáng, Bữa trưa, Bữa tối, Bữa phụ*), select dishes from multiple sources (the 35+ Vietnamese National Database, user-created Custom Foods, and Personal Recipes), calculate real-time daily nutritional projections without inflating actual diary intake, duplicate days, and atomically log planned meals directly into the actual Meal Diary with custom portion corrections.

### Key Milestones Achieved
1. **Domain Layer:** Built [`WeeklyMealPlan`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/WeeklyMealPlan.swift), [`PlannedMeal`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/PlannedMeal.swift), [`PlannedFoodItem`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/PlannedFoodItem.swift), and [`MealPlanCalendarHelper`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Services/MealPlanCalendarHelper.swift) with timezone-aware Monday-to-Sunday handling, year/month boundary support, and immutable nutritional snapshotting.
2. **SwiftData Schema:** Extended [`SwiftDataStack`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/Persistence/SwiftDataStack.swift) with [`PlannedMealSDModel`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/LocalStorage/SwiftDataEntities.swift#L628-L685) and [`PlannedFoodItemSDModel`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/LocalStorage/SwiftDataEntities.swift#L571-L626) with cascade deletion rules, preserving 100% of historical diary logs, hydration records, custom foods, and recipes.
3. **Repository & Use Cases:** Implemented [`MealPlanRepository`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/Repositories/MealPlanRepository.swift) and [`MockMealPlanRepository`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/Repositories/MockMealPlanRepository.swift) with dedicated Use Cases for weekly queries, atomic diary logging, status management, day copying, and meal planning.
4. **Presentation Layer (Fresh Premium Botanical):** Built [`WeeklyMealPlannerView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/WeeklyMealPlannerView.swift), [`WeeklyCalendarStripView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/WeeklyCalendarStripView.swift), [`PlannedMealCardView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/PlannedMealCardView.swift), [`AddPlannedMealSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/AddPlannedMealSheet.swift), [`PlannedFoodSourcePickerSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/PlannedFoodSourcePickerSheet.swift), [`PlannedMealDetailSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/PlannedMealDetailSheet.swift), [`CopyDayPlanSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/CopyDayPlanSheet.swift), and [`LogPlannedMealConfirmationSheet`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/WeeklyMealPlanner/LogPlannedMealConfirmationSheet.swift).
5. **Diary Integration:** Created [`LogPlannedMealToDiaryUseCase`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/UseCases/LogPlannedMealToDiaryUseCase.swift), ensuring planned meals never affect actual daily totals until confirmed, preventing duplicate logging, and supporting portion correction.
6. **Automated Testing & UI Verification:** Expanded the automated test suite with 17 new unit tests in [`WeeklyMealPlannerTests.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLensTests/UnitTests/WeeklyMealPlannerTests.swift) and an end-to-end UI test in [`NutriLensUITests.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLensUITests/NutriLensUITests.swift). All 112 automated tests passed with 0 failures (104 unit + 8 UI).

---

## 2. Architecture & Data Flow

```
                      +---------------------------------------+
                      |         WeeklyMealPlannerView         |
                      +---------------------------------------+
                                          |
                      +---------------------------------------+
                      |      WeeklyMealPlannerViewModel       |
                      +---------------------------------------+
                                          |
            +-----------------------------+-----------------------------+
            |                             |                             |
+------------------------+   +------------------------+   +----------------------------+
| GetWeeklyMealPlan      |   | CopyDayPlanUseCase     |   | LogPlannedMealToDiary      |
| UseCase                |   |                        |   | UseCase                    |
+------------------------+   +------------------------+   +----------------------------+
            |                             |                             |
            +-----------------------------+                             |
                                          |                             v
                      +---------------------------------------+   +-------------------+
                      |      MealPlanRepositoryProtocol       |   | MealRepository    |
                      +---------------------------------------+   | (Actual Diary)    |
                                          |                       +-------------------+
                      +---------------------------------------+
                      |          MealPlanRepository           |
                      |              (SwiftData)              |
                      +---------------------------------------+
                                          |
            +-----------------------------+-----------------------------+
            |                                                           |
+------------------------+                                 +------------------------+
|   PlannedMealSDModel   |                                 | PlannedFoodItemSDModel |
+------------------------+                                 +------------------------+
```

### Planned vs Actual Nutrition Separation
- **Planned Nutrition:** Calculated dynamically inside [`WeeklyMealPlan`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/WeeklyMealPlan.swift#L47-L59) and displayed in the Daily Overview banner as a reference target (*"Dự tính thực đơn"*).
- **Actual Diary Nutrition:** The Home Dashboard and Nutrition Analytics modules query `MealRepository` strictly for recorded `MealRecord` instances. Planned meals never contribute to caloric or macronutrient consumption until the user completes the *"Đã ăn — Ghi vào nhật ký"* flow.

---

## 3. Domain Models & Entities

### [`WeeklyMealPlan`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/WeeklyMealPlan.swift)
Represents the complete 7-day period starting Monday:
- `weekStartDate: Date` (Monday 00:00:00)
- `weekEndDate: Date` (Sunday 23:59:59)
- `plannedMeals: [PlannedMeal]`
- `totalPlannedMealsCount`, `completedMealsCount`, `skippedMealsCount`
- `meals(for:category:calendar:)`: Grouped meals for a day and category
- `estimatedDailyNutrition(for:calendar:)`: Real-time daily macro sum

### [`PlannedMeal`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/PlannedMeal.swift)
- `id: UUID` (stable unique identifier)
- `scheduledDate: Date`
- `mealCategory: PlannedMealCategory` (`.breakfast`, `.lunch`, `.dinner`, `.snack`)
- `foodItems: [PlannedFoodItem]`
- `notes: String?`
- `status: PlannedMealStatus` (`.planned`, `.completed`, `.skipped`)
- `linkedDiaryRecordId: UUID?`
- `duplicate(forDate:)`: Produces a clean replica with a new UUID and resets status to `.planned`

### [`PlannedFoodItem`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/PlannedFoodItem.swift)
- `id: UUID`
- `sourceType: PlannedFoodSourceType` (`.vietnameseDatabase`, `.customFood`, `.recipe`, `.manual`)
- `sourceId: String?` (slug or UUID)
- `displayName: String`
- `quantity: Double`
- `servingUnit: String`
- `portionMultiplier: Double`
- `nutritionSnapshot: PlannedNutritionSnapshot` (energy, protein, carbohydrates, fat, fiber)
- `toFoodItem()`: Converts into an immutable [`FoodItem`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/FoodItem.swift) for the actual Meal Diary

---

## 4. UI/UX Implementation & Verified Flows

All screens adhere to the **Fresh Premium Botanical** design system:

| # | Screen / Sheet | Key Features Verified |
|---|---|---|
| 1 | **Weekly Planner Overview** | Top bar with Dynamic Island clearance, week `<` `>` navigator, 7-day Monday-to-Sunday strip with active dots, daily planned macro summary, 4 categorized meal sections with quick action buttons. |
| 2 | **Add / Edit Planned Meal** | Date selector, 4 meal category tabs, staged food tray, live macro calculation, notes editor, validation against empty meals. |
| 3 | **Multi-Source Food Picker** | 3-tab segmented picker (*Món Việt 35+*, *Món của bạn*, *Công thức*), real-time diacritic-insensitive search, portion adjustment slider with live nutrition calculation. |
| 4 | **Planned Meal Detail** | Full dish breakdown with individual macros, status switcher, one-tap *"Đã ăn — Ghi vào nhật ký"* CTA, duplicate to tomorrow, edit, and delete. |
| 5 | **Copy Day Plan** | Source day preview, target date picker, mode switcher (*Append* vs *Replace* with warning confirmation dialog). |
| 6 | **Diary Logging Confirmation** | Portion correction slider (*Ăn nhiều hơn / ít hơn*), timestamp and meal type overrides, atomic persistence to `MealRepository` and link updating. |

---

## 5. Visual Simulator Evidence (iPhone 17, iOS 26.5)

| Screenshot | Description | File Path |
|---|---|---|
| `1_weekly_planner_overview.png` | 7-day planner overview with Monday-to-Sunday calendar bar, daily overview, and categorized planned meals | [`reports/screenshots/phase04/1_weekly_planner_overview.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/1_weekly_planner_overview.png) |
| `2_add_planned_meal.png` | Add planned meal modal with date, category, and food tray | [`reports/screenshots/phase04/2_add_planned_meal.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/2_add_planned_meal.png) |
| `3_multi_source_food_picker.png` | 3-source picker with Vietnamese DB, Custom Foods, and Recipes | [`reports/screenshots/phase04/3_multi_source_food_picker.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/3_multi_source_food_picker.png) |
| `4_planned_meal_detail.png` | Detailed inspection with macro columns and direct diary logging CTA | [`reports/screenshots/phase04/4_planned_meal_detail.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/4_planned_meal_detail.png) |
| `5_copy_day_plan.png` | Copy day schedule with Append / Replace confirmation | [`reports/screenshots/phase04/5_copy_day_plan.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/5_copy_day_plan.png) |
| `6_diary_logging_confirmation.png` | Diary confirmation dialog with interactive actual portion adjustment slider | [`reports/screenshots/phase04/6_diary_logging_confirmation.png`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase04/6_diary_logging_confirmation.png) |

---

## 6. Automated Test Suite Metrics

```
Executed 104 Unit Tests, with 0 failures (0 unexpected) in 0.818 seconds
Executed 8 UI Tests, with 0 failures (0 unexpected) in 231.671 seconds
Total: 112 Tests Passing • 100% Pass Rate
```

### Verified Test Cases in `WeeklyMealPlannerTests.swift`
1. `testWeeklyDateRangeCalculation`: Verified Monday 00:00:00 to Sunday 23:59:59 week definition.
2. `testWeekNavigation`: Verified 7-day backward/forward step calculation across month boundaries.
3. `testCalendarBoundaryCases`: Verified leap years, October-to-November and December-to-January year transitions.
4. `testCreatePlannedMeal`: Verified saving and retrieving planned meals with single and multiple items.
5. `testUpdatePlannedMeal`: Verified updating meal properties, notes, and category.
6. `testDeletePlannedMeal`: Verified cascade deletion of planned meals and associated items.
7. `testPlannedNutritionCalculations`: Verified additive macro summation.
8. `testSourceNutritionSnapshotIntegrity`: Verified immutable snapshot calculation from food sources.
9. `testAddCustomFoodToPlan`: Verified adding custom foods created in Phase 03.
10. `testAddRecipeToPlan`: Verified adding scaled recipes created in Phase 03.
11. `testCopyDayPlan`: Verified both Append and Replace modes with fresh UUID allocation.
12. `testDuplicateMeal`: Verified duplicate logic for next-day planning.
13. `testMarkSkippedAndRestore`: Verified status state transitions.
14. `testLogPlannedMealToDiary`: Verified atomic creation of `MealRecord`, persistence to `MealRepository`, and status update.
15. `testPreventDuplicateDiaryLogging`: Verified duplicate log attempts throw `AppError.invalidInput`.
16. `testFailedDiaryPersistenceRollback`: Verified planned meal remains untouched if diary persistence fails.
17. `testSwiftDataPersistence`: Verified in-memory SwiftData container round-trip for `PlannedMealSDModel` and `PlannedFoodItemSDModel`.

---

## 7. Known Limitations & Phase 05 Readiness Assessment

### Current Scope Boundaries
- **Grocery List Generator:** Generating automated grocery shopping lists based on planned ingredients will be introduced in Phase 05.
- **Micro-Target Auto-Balancing:** Smart suggestions based on daily caloric deficiencies will be integrated in Phase 05/06.
- **Cloud Synchronization:** Offline-first architecture is strictly maintained; cloud sync is omitted as specified.

### Phase 05 Readiness: GREEN
- Architecture is clean, decoupled, and thoroughly tested.
- SwiftData models are registered safely in `SwiftDataStack`.
- Navigation preserves the native 5-tab structure with intuitive entry points from both `HomeView` and `FoodExplorerView`.
- All Phase 03 and Phase 04 changes remain local and intact.

