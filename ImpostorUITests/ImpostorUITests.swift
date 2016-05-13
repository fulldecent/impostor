//
//  ImpostorUITests.swift
//  ImpostorUITests
//
//  Created by Full Decent on 4/14/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import XCTest

class ImpostorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        let app = XCUIApplication()
        
        let minusButton = app.buttons["minus"]
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        snapshot("01Configuration")

        app.buttons["startGame"].tap()
        snapshot("02Player")

        let showSecretWordButton = app.buttons["showSecretWord"]
        showSecretWordButton.tap()
        snapshot("03Secret")
g    }
    
}

