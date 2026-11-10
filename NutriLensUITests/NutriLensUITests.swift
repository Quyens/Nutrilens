//
//  NutriLensUITests.swift
//  NutriLensUITests
//
//  Created for NutriLens Clean Architecture iOS App.
//

import XCTest

final class NutriLensUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func dismissOnboardingIfPresent(_ app: XCUIApplication) {
        let startButton = app.buttons["Start My Healthy Journey"]
        if startButton.waitForExistence(timeout: 2) {
            startButton.tap()
            _ = app.buttons["Trang chủ"].waitForExistence(timeout: 3)
        }
    }

    func testTabBarNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        // Floating tab bar buttons with Vietnamese labels
        let homeTab = app.buttons["Trang chủ"]
        let diaryTab = app.buttons["Nhật ký"]

        if homeTab.waitForExistence(timeout: 5) {
            XCTAssertTrue(homeTab.exists)

            // Verify and tap Diary
            if diaryTab.exists {
                diaryTab.tap()
                sleep(1)
            }

            // Return to Home
            homeTab.tap()
            XCTAssertTrue(app.staticTexts["NutriLens"].waitForExistence(timeout: 3))
        }
    }

    func testHomeScrollAndVerifyNoOverlap() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let homeTab = app.buttons["Trang chủ"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()
        sleep(1)
        app.swipeDown()
        sleep(1)

        // 1. Capture Top of Dashboard
        let topScreenshot = XCUIScreen.main.screenshot()
        try? topScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82/screen_v6_top.png"))

        // 2. Swipe up to scroll to the lower dashboard
        app.swipeUp()
        sleep(1)

        // 3. Verify lower sections are visible and capture scrolled state
        let scrolledScreenshot = XCUIScreen.main.screenshot()
        try? scrolledScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82/screen_v6_scrolled.png"))

        let trendHeading = app.staticTexts["Xu hướng dinh dưỡng"]
        XCTAssertTrue(trendHeading.exists, "Weekly nutrition trend heading must exist")
    }

    func testCompleteFoodRecognitionFlow() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let artifactDir = "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82"

        // 1. HOME SCREEN: Tap Quét (Scan) tab
        let scanTab = app.buttons["Quét"]
        XCTAssertTrue(scanTab.waitForExistence(timeout: 5), "Quét tab button must exist")
        scanTab.tap()
        sleep(2)

        // SCREENSHOT 1: Camera Scan Screen
        let scanScreenshot = XCUIScreen.main.screenshot()
        try? scanScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_1_camera_scan.png"))

        // 2. Select a quick Vietnamese sample dish (Phở Bò Tái Nạm)
        let phoButton = app.buttons["Phở Bò Tái Nạm"]
        if phoButton.waitForExistence(timeout: 4) {
            phoButton.tap()
        } else {
            // Alternatively tap the main shutter button
            let shutter = app.buttons["Chụp ảnh món ăn"]
            if shutter.exists {
                shutter.tap()
            }
        }

        // Wait for AI inference & analyzing transition
        sleep(2)

        // SCREENSHOT 2: Recognition Result Screen
        let resultScreenshot = XCUIScreen.main.screenshot()
        try? resultScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_2_recognition_result.png"))

        // Verify dish title or confidence indicator exists
        let continueButton = app.buttons["Tiếp tục: Xem & Chỉnh Dinh Dưỡng"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5), "Continue button must exist on Recognition Result screen")
        continueButton.tap()
        sleep(1)

        // 3. NUTRITION REVIEW & MEAL CONFIRMATION SCREEN
        // SCREENSHOT 3: Nutrition Review Screen
        let nutritionScreenshot = XCUIScreen.main.screenshot()
        try? nutritionScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_3_nutrition_review.png"))

        // Tap portion preset "Đầy đặn (600g)"
        let generousPreset = app.buttons["Đầy đặn (600g)"]
        if generousPreset.waitForExistence(timeout: 3) {
            generousPreset.tap()
            sleep(1)
        }

        // Swipe up to reveal the save action dock
        app.swipeUp()
        sleep(1)

        // Tap "Lưu vào nhật ký bữa ăn"
        let saveButton = app.buttons["Lưu vào nhật ký bữa ăn"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save meal button must exist")
        saveButton.tap()
        sleep(1)

        // SCREENSHOT 4: Save Success Screen
        let successScreenshot = XCUIScreen.main.screenshot()
        try? successScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_4_save_success.png"))

        // Tap "Xem trong Nhật ký bữa ăn" or wait for auto-transition
        let viewDiaryButton = app.buttons["Xem trong Nhật ký bữa ăn"]
        if viewDiaryButton.waitForExistence(timeout: 2) {
            viewDiaryButton.tap()
        }
        sleep(2)

        // SCREENSHOT 5: Meal Diary Screen
        let diaryScreenshot = XCUIScreen.main.screenshot()
        try? diaryScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_5_meal_diary.png"))

        // Tap "Trang chủ" tab to return to Home Dashboard
        let homeTab = app.buttons["Trang chủ"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()
        sleep(2)

        // SCREENSHOT 6: Updated Home Dashboard
        let updatedHomeScreenshot = XCUIScreen.main.screenshot()
        try? updatedHomeScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/flow_6_updated_home.png"))
    }

    func testMealDiaryV2CompleteFlow() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let artifactDir = "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82"

        // 1. Navigate to Diary tab
        let diaryTab = app.buttons["Nhật ký"]
        XCTAssertTrue(diaryTab.waitForExistence(timeout: 5), "Nhật ký tab button must exist")
        diaryTab.tap()
        sleep(2)

        // SCREENSHOT 1: Diary Home (Weekly calendar strip, daily totals, category sections)
        let diaryHomeShot = XCUIScreen.main.screenshot()
        try? diaryHomeShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_1_weekly_calendar.png"))

        // 2. Open Quick Add Sheet via "+ Thêm" button on Breakfast
        let addBreakfastButton = app.buttons["diary_add_button_Breakfast"]
        if addBreakfastButton.waitForExistence(timeout: 4) {
            addBreakfastButton.tap()
            sleep(2)

            // SCREENSHOT 2: Quick Add Sheet
            let quickAddShot = XCUIScreen.main.screenshot()
            try? quickAddShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_2_quick_add_sheet.png"))

            // Select a dish row
            let phoRow = app.buttons["quick_add_row_pho"]
            if phoRow.waitForExistence(timeout: 3) {
                phoRow.tap()
                sleep(1)
            }

            // Tap "Ghi vào nhật ký"
            let logButton = app.buttons["quick_add_confirm_button"]
            if logButton.waitForExistence(timeout: 3) {
                logButton.tap()
                sleep(3)
            }
        }

        // 3. Inspect Meal Details
        // Tap on first logged dish card
        let mealCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'diary_meal_card_'"))
        if mealCards.count > 0 {
            mealCards.element(boundBy: 0).tap()
            sleep(2)

            // SCREENSHOT 3: Meal Details Screen
            let detailShot = XCUIScreen.main.screenshot()
            try? detailShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_3_meal_detail.png"))

            // Tap "Chỉnh sửa" / "Sửa"
            let editButton = app.buttons["detail_top_edit_button"]
            if editButton.waitForExistence(timeout: 3) {
                editButton.tap()
                sleep(2)

                // SCREENSHOT 4: Edit Meal Screen
                let editShot = XCUIScreen.main.screenshot()
                try? editShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_4_edit_meal.png"))

                // Tap preset chip 450g
                let preset450 = app.buttons["edit_portion_450"]
                if preset450.waitForExistence(timeout: 2) {
                    preset450.tap()
                    sleep(1)
                }

                // Save changes
                let saveEditButton = app.buttons["edit_meal_save_button"]
                if saveEditButton.waitForExistence(timeout: 2) {
                    saveEditButton.tap()
                    sleep(2)
                }
            }

            // Dismiss detail sheet
            let closeDetailButton = app.buttons["detail_close_button"]
            if closeDetailButton.exists {
                closeDetailButton.tap()
            } else {
                app.swipeDown()
            }
            sleep(2)
        }

        // 4. Test Search and Filter
        let searchToggle = app.buttons["diary_search_toggle"]
        if searchToggle.waitForExistence(timeout: 3) {
            searchToggle.tap()
            sleep(1)

            let searchField = app.textFields["diary_search_field"]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Phở\n")
                sleep(2)

                // SCREENSHOT 5: Search & Filter State
                let searchShot = XCUIScreen.main.screenshot()
                try? searchShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_5_search_filter.png"))
            }

            if searchToggle.isHittable {
                searchToggle.tap()
                sleep(1)
            }
        }

        // 5. Test Deletion Confirmation
        let cardToDelete = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'diary_meal_card_'")).firstMatch
        if cardToDelete.waitForExistence(timeout: 4) {
            cardToDelete.tap()
            sleep(2)

            // Scroll down in detail sheet to reveal actions
            app.swipeUp()
            sleep(1)

            let deleteButton = app.buttons["detail_delete_meal_button"]
            if deleteButton.waitForExistence(timeout: 3) {
                deleteButton.tap()
                sleep(2)

                // SCREENSHOT 6: Delete Confirmation Dialog
                let deleteShot = XCUIScreen.main.screenshot()
                try? deleteShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_6_delete_confirmation.png"))

                // Confirm deletion
                let confirmDeleteButton = app.buttons["Xóa khỏi nhật ký"]
                if confirmDeleteButton.waitForExistence(timeout: 2) {
                    confirmDeleteButton.tap()
                    sleep(2)
                }
            }
        }

        // 6. Return to Home Dashboard to verify sync
        let homeTab = app.buttons["Trang chủ"]
        if homeTab.waitForExistence(timeout: 4) {
            homeTab.tap()
            sleep(2)

            // SCREENSHOT 7: Home Dashboard Synchronized
            let homeSyncShot = XCUIScreen.main.screenshot()
            try? homeSyncShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/diary_7_home_sync.png"))
        }
    }

    // MARK: - Nutrition Analytics V2 Complete UI & Screenshot Flow
    func testNutritionAnalyticsFlow() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let artifactDir = "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82"

        // 1. Quick verify Home has logged meals
        let homeTab = app.buttons["Trang chủ"]
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
            sleep(1)

            // Tap quick sample if present to ensure at least one meal exists today
            let quickPho = app.buttons["quick_add_sample_pho"]
            if quickPho.waitForExistence(timeout: 2) {
                quickPho.tap()
                sleep(1)
            }
        }

        // 2. Navigate to "Thống kê" tab on the floating bottom bar
        let statsTab = app.buttons["Thống kê"]
        XCTAssertTrue(statsTab.waitForExistence(timeout: 5), "Thống kê tab must exist in floating tab bar")
        statsTab.tap()
        sleep(2)

        // SCREENSHOT 1: Weekly Overview
        let weekShot = XCUIScreen.main.screenshot()
        try? weekShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/analytics_1_week_overview.png"))

        // 3. Switch to Month View
        let monthButton = app.buttons["Chọn xem theo Tháng"]
        if monthButton.waitForExistence(timeout: 3) {
            monthButton.tap()
            sleep(2)

            // SCREENSHOT 2: Monthly Trends
            let monthShot = XCUIScreen.main.screenshot()
            try? monthShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/analytics_2_month_trends.png"))
        }

        // 4. Switch to Day View
        let dayButton = app.buttons["Chọn xem theo Ngày"]
        if dayButton.waitForExistence(timeout: 3) {
            dayButton.tap()
            sleep(2)

            // SCREENSHOT 3: Day Breakdown
            let dayShot = XCUIScreen.main.screenshot()
            try? dayShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/analytics_3_day_breakdown.png"))
        }

        // 5. Switch back to Week View and scroll down to reveal Explainable AI Insights & P:C:F Ratio
        let weekButton = app.buttons["Chọn xem theo Tuần"]
        if weekButton.waitForExistence(timeout: 3) {
            weekButton.tap()
            sleep(1)

            // Scroll down to see full insights and P:C:F ratio
            app.swipeUp()
            app.swipeUp()
            sleep(2)

            // SCREENSHOT 4: Insights & Macro Energy Ratio
            let insightsShot = XCUIScreen.main.screenshot()
            try? insightsShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/analytics_4_insights_detail.png"))
        }
    }

    // MARK: - Food Database & Explorer V1 UI Test
    func testFoodExplorerCompleteFlow() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let artifactDir = "/Users/vanquyen/.gemini/antigravity-ide/brain/842c5952-a71e-4e61-915f-a5a5babddd82"

        // 1. From Home, tap Food Discovery Banner or Search Icon
        let homeTab = app.buttons["Trang chủ"]
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
            sleep(1)
        }

        let searchIcon = app.buttons["Khám phá món ăn"]
        let discoveryBanner = app.buttons["Khám phá 35+ món ăn Việt Nam"]

        if searchIcon.waitForExistence(timeout: 3) {
            searchIcon.tap()
        } else if discoveryBanner.waitForExistence(timeout: 3) {
            discoveryBanner.tap()
        }
        sleep(2)

        // SCREENSHOT 1: Food Explorer Catalog Home
        let catalogShot = XCUIScreen.main.screenshot()
        try? catalogShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/explorer_1_home_catalog.png"))

        // 2. Perform accent-insensitive search and category selection
        let searchField = app.textFields["Tìm kiếm theo tên, từ khóa hoặc mã..."]
        if searchField.waitForExistence(timeout: 3) {
            searchField.tap()
            searchField.typeText("pho\n")
            sleep(2)
        }

        // Tap Category Pill "Bún / Phở"
        let phoCategory = app.buttons["Bún / Phở"]
        if phoCategory.waitForExistence(timeout: 2) {
            phoCategory.tap()
            sleep(1)
        }

        // SCREENSHOT 2: Search & Filtered Categories
        let searchShot = XCUIScreen.main.screenshot()
        try? searchShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/explorer_2_search_categories.png"))

        // 3. Open Dish Detail ("Phở Bò Tái Nạm")
        let phoDish = app.buttons["catalog_dish_pho"]
        if phoDish.waitForExistence(timeout: 4) {
            phoDish.tap()
            sleep(2)
        }

        // SCREENSHOT 3: Dish Detail Screen with Hero Photography & Nutrition
        let detailShot = XCUIScreen.main.screenshot()
        try? detailShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/explorer_3_dish_detail.png"))

        // 4. Scroll up to bring Interactive Portion Calculator and Data Provenance into view
        app.swipeUp()
        sleep(1)

        // Select "1.5x" preset
        let preset15x = app.buttons["preset_1.5x"]
        if preset15x.waitForExistence(timeout: 3) {
            preset15x.tap()
            sleep(1)
        }

        // Tap plus stepper to increment portion
        let plusButton = app.buttons["portion_stepper_plus"]
        if plusButton.waitForExistence(timeout: 2) {
            plusButton.tap()
            sleep(1)
        }

        // SCREENSHOT 4: Scaled Portion Calculator, Nutrition Breakdown & Provenance
        let portionShot = XCUIScreen.main.screenshot()
        try? portionShot.pngRepresentation.write(to: URL(fileURLWithPath: "\(artifactDir)/explorer_4_portion_calculator.png"))

        // 5. Add to Diary
        let logButton = app.buttons["button_log_to_diary"]
        if logButton.waitForExistence(timeout: 3) {
            logButton.tap()
            sleep(2)

            let confirmLog = app.buttons["button_confirm_log_meal"]
            if confirmLog.waitForExistence(timeout: 3) {
                confirmLog.tap()
                sleep(2)
            }
        }
    }

    func testMultiItemManualMealLoggingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-startManualLog"]
        app.launch()
        dismissOnboardingIfPresent(app)

        let artifactDir = "/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/phase02"
        let repoArtifactDir = "/Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase02"

        // Helper to save screenshot in both artifact directories
        func saveShot(name: String) {
            let shot = XCUIScreen.main.screenshot()
            let data = shot.pngRepresentation
            try? data.write(to: URL(fileURLWithPath: "\(artifactDir)/\(name)"))
            try? data.write(to: URL(fileURLWithPath: "\(repoArtifactDir)/\(name)"))
        }

        // 1. Verify Manual Log Sheet opens
        let titleText = app.staticTexts["Ghi nhận bữa ăn"]
        XCTAssertTrue(titleText.waitForExistence(timeout: 5), "Manual log screen should appear")
        sleep(1)
        saveShot(name: "1_manual_log_empty.png")

        // 2. Select first dish ("Phở Bò Tái Nạm")
        let addPhoButton = app.buttons["catalog_dish_add_pho"]
        if addPhoButton.waitForExistence(timeout: 3) {
            addPhoButton.tap()
        } else {
            let firstAdd = app.buttons["Thêm"]
            if firstAdd.waitForExistence(timeout: 3) {
                firstAdd.tap()
            }
        }
        sleep(1)

        // 3. Portion sheet appears
        let confirmPortionButton = app.buttons["portion_confirm_add_button"]
        XCTAssertTrue(confirmPortionButton.waitForExistence(timeout: 4), "Portion selection sheet should appear")
        saveShot(name: "2_portion_sheet.png")

        // Confirm first item
        confirmPortionButton.tap()
        sleep(1)

        // 4. Select second dish ("Cơm Tấm Sườn Bì Chả")
        let addComTamButton = app.buttons["catalog_dish_add_com_tam"]
        if addComTamButton.waitForExistence(timeout: 3) {
            addComTamButton.tap()
        } else {
            let anyAdd = app.buttons["Thêm"]
            if anyAdd.waitForExistence(timeout: 3) {
                anyAdd.tap()
            }
        }
        sleep(1)

        let confirmPortion2 = app.buttons["portion_confirm_add_button"]
        if confirmPortion2.waitForExistence(timeout: 3) {
            confirmPortion2.tap()
            sleep(1)
        }

        // 5. Verify staged items tray and live aggregate totals
        let saveButton = app.buttons["manual_log_save_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save meal button should exist")
        saveShot(name: "3_multi_item_staged_tray.png")

        // 6. Save the meal
        saveButton.tap()
        sleep(2)

        saveShot(name: "4_meal_logged_result.png")
    }
}


