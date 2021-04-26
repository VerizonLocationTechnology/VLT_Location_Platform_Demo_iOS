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
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.welcomeTitle].exists)
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.cameraTitle].exists)
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.modesTitle].exists)
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.userLocationTitle].exists)
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.shapesTitle].exists)
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.listenersTitle].exists)
    }

    func testCamera() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.cameraTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.cameraTitle].tap()
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.cameraTitle].exists)
        XCTAssert(app.buttons["add"].exists) // XCTAssert(app.buttons["plus"].exists)
        XCTAssert(app.buttons["remove"].exists) // XCTAssert(app.buttons["minus"].exists)
        app.buttons[VLTLiterals.CameraMetricsVCLiterals.title].tap()
        XCTAssert(app.staticTexts["Zoom Level"].exists)
        XCTAssert(app.staticTexts["Bearing"].exists)
        XCTAssert(app.staticTexts["Tilt"].exists)
        app.staticTexts["Update"].tap()
    }

    func testModes() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.modesTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.modesTitle].tap()
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.modesTitle].exists)
        app.buttons["Day"].tap()
        XCTAssert(app.buttons["Day"].isSelected == true)
        XCTAssert(app.buttons["Dark"].isSelected == false)
        XCTAssert(app.buttons["Satellite"].isSelected == false)
        app.buttons["Dark"].tap()
        XCTAssert(app.buttons["Day"].isSelected == false)
        XCTAssert(app.buttons["Dark"].isSelected == true)
        XCTAssert(app.buttons["Satellite"].isSelected == false)
        app.buttons["Satellite"].tap()
        XCTAssert(app.buttons["Day"].isSelected == false)
        XCTAssert(app.buttons["Dark"].isSelected == false)
        XCTAssert(app.buttons["Satellite"].isSelected == true)
    }

    func testUserLocation() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.userLocationTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.userLocationTitle].tap()
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.userLocationTitle].exists)
    }

    func testShapes() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.shapesTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.shapesTitle].tap()
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.shapesTitle].exists)
        XCTAssert(app.staticTexts["Traffic Flow"].exists)
        app.buttons["List"].tap()
        app.staticTexts["Circle"].tap()
        app.staticTexts["Marker"].tap()
        app.staticTexts["Polyline"].tap()
        app.staticTexts["Polygon"].tap()
        app.staticTexts["Traffic Incidents"].tap()
        app.buttons[VLTLiterals.DemoFeatureLiterals.shapesTitle].tap()
        XCTAssert(app.staticTexts["Circle"].exists)
        XCTAssert(app.staticTexts["Marker"].exists)
        XCTAssert(app.staticTexts["Polyline"].exists)
        XCTAssert(app.staticTexts["Polygon"].exists)
        XCTAssert(app.staticTexts["Traffic Incidents"].exists)
    }

    func testGeoJSON() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.geoJsonTitle].exists)
        app.staticTexts["GeoJSON"].tap()
        app.staticTexts["Polylines"].tap()
    }

    func testListeners() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.listenersTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.listenersTitle].tap()
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.listenersTitle].exists)
        XCTAssert(app.staticTexts["Traffic Flow"].exists)
    }

    func testRelativePositioning() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.relativePositioningTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.relativePositioningTitle].tap()
    }

    func testBoundingBox() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.boundingBoxTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.boundingBoxTitle].tap()
    }

    func testMapboxIntegration() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.mapboxTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.mapboxTitle].tap()
    }

    func testNavigation() {
        XCTAssert(app.staticTexts[VLTLiterals.DemoFeatureLiterals.navigationTitle].exists)
        app.staticTexts[VLTLiterals.DemoFeatureLiterals.navigationTitle].tap()
    }
}
