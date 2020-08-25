//
//  VLTDemoMapsSDKUITests.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import XCTest

let app = XCUIApplication()
let tablesQuery = app.tables

class VLTDemoMapsSDKUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
    }

    func testHomeScreenElements() {
        XCTAssert(app.staticTexts["Welcome."].exists)
        XCTAssert(app.staticTexts["Camera"].exists)
        XCTAssert(app.staticTexts["Modes"].exists)
        XCTAssert(app.staticTexts["User Location"].exists)
        XCTAssert(app.staticTexts["Shapes"].exists)
        XCTAssert(app.staticTexts["Listeners"].exists)
    }

    func testCamera() {
        XCTAssert(app.staticTexts["Camera"].exists)
        app.staticTexts["Camera"].tap()
        XCTAssert(app.staticTexts["Camera"].exists)
        XCTAssert(app.buttons["plus"].exists)
        XCTAssert(app.buttons["minus"].exists)
        app.buttons["Metrics"].tap()
        XCTAssert(app.staticTexts["Zoom Level"].exists)
        XCTAssert(app.staticTexts["Bearing"].exists)
        XCTAssert(app.staticTexts["Tilt"].exists)
        app.staticTexts["Update"].tap()
    }

    func testModes() {
        XCTAssert(app.staticTexts["Modes"].exists)
        app.staticTexts["Modes"].tap()
        XCTAssert(app.staticTexts["Modes"].exists)
        XCTAssert(app.buttons["Day"].isSelected == true)
        XCTAssert(app.buttons["Dark"].isSelected == false)
        XCTAssert(app.buttons["Satellite"].isSelected == false)
        app.buttons["Dark"].tap()
        XCTAssert(app.buttons["Dark"].isSelected == true)
        XCTAssert(app.buttons["Day"].isSelected == false)
        XCTAssert(app.buttons["Satellite"].isSelected == false)
        app.buttons["Satellite"].tap()
        XCTAssert(app.buttons["Satellite"].isSelected == true)
        XCTAssert(app.buttons["Day"].isSelected == false)
        XCTAssert(app.buttons["Dark"].isSelected == false)
    }

    func testUserLocation() {
        XCTAssert(app.staticTexts["User Location"].exists)
        app.staticTexts["User Location"].tap()
        XCTAssert(app.staticTexts["User Location"].exists)

    }

    func testShapes() {
        XCTAssert(app.staticTexts["Shapes"].exists)
        app.staticTexts["Shapes"].tap()
        XCTAssert(app.staticTexts["Shapes & Markers"].exists)
        XCTAssert(app.staticTexts["Traffic"].exists)
        app.buttons["List"].tap()
        app.staticTexts["Circle"].tap()
        app.staticTexts["Marker"].tap()
        app.staticTexts["Polyline"].tap()
        app.staticTexts["Polygon"].tap()
        app.buttons["Shapes & Markers"].tap()
        XCTAssert(app.staticTexts["Circle"].exists)
        XCTAssert(app.staticTexts["Marker"].exists)
        XCTAssert(app.staticTexts["Polyline"].exists)
        XCTAssert(app.staticTexts["Polygon"].exists)

    }

    func testListeners() {
        XCTAssert(app.staticTexts["Listeners"].exists)
        app.staticTexts["Listeners"].tap()
        XCTAssert(app.staticTexts["Shapes & Markers"].exists)
        XCTAssert(app.staticTexts["Traffic"].exists)
    }
}
