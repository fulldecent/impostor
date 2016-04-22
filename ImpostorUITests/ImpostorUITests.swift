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
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        let app = XCUIApplication()
//        let button = app.buttons["      "]
//        button.tap()
//        snapshot("05Teaser")
        
        let minusButton = app.buttons["minus"]
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        minusButton.tap()
        snapshot("01Configuration")

        app.buttons["Start Game"].tap()
        snapshot("02Player")

        let showSecretWordButton = app.buttons["Show secret word"]
        showSecretWordButton.tap()
        snapshot("03Secret")
        
        let okButton = app.buttons["OK"]
        okButton.tap()
        showSecretWordButton.tap()
        okButton.tap()
        showSecretWordButton.tap()
        okButton.tap()
        okButton.tap()
        snapshot("04Eliminate")
    }
    
}

