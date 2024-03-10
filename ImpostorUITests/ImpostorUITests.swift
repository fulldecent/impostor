//
//  ImpostorUITests.swift
//  ImpostorUITests
//
//  Created by William Entriken on 2023-12-31.
//

import XCTest

final class ImpostorUITests: XCTestCase {
    var app: XCUIApplication!
    
    @MainActor
    override func setUp() async throws {
        app = XCUIApplication()
//        setupSnapshot(app)
        app.launch()
    }

    @MainActor
    func testScreenshotLibrary() throws {
//      snapshot("Library")
    }
}
