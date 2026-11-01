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

    func testTabBarNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Tab bar items
        let homeTab = app.tabBars.buttons["Home"]
        let scanTab = app.tabBars.buttons["Scan"]
        let historyTab = app.tabBars.buttons["History"]
        let profileTab = app.tabBars.buttons["Profile"]

        if homeTab.waitForExistence(timeout: 5) {
            XCTAssertTrue(homeTab.exists)

            scanTab.tap()
            XCTAssertTrue(app.navigationBars["Food Scanner"].waitForExistence(timeout: 3))

            historyTab.tap()
            XCTAssertTrue(app.navigationBars["Meal History"].waitForExistence(timeout: 3))

            profileTab.tap()
            XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 3))

            homeTab.tap()
            XCTAssertTrue(app.navigationBars["NutriLens"].waitForExistence(timeout: 3))
        }
    }
}
