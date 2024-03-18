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
        setupSnapshot(app)
        app.launch()
    }

    @MainActor
    func testMainPlay() throws {
        snapshot("1. Config")
        
        app/*@START_MENU_TOKEN@*/.buttons["startGame"]/*[[".buttons[\"Play\"]",".buttons[\"startGame\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("2. Secret")
        
        let seeSecretwordButton = app/*@START_MENU_TOKEN@*/.buttons["seeSecretWord"]/*[[".buttons[\"Show\"]",".buttons[\"seeSecretWord\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        seeSecretwordButton.tap()
        snapshot("3. A word")
        app.alerts.firstMatch.scrollViews.otherElements.buttons.firstMatch.tap()

        seeSecretwordButton.tap()
        app.alerts.firstMatch.scrollViews.otherElements.buttons.firstMatch.tap()
        
        seeSecretwordButton.tap()
        app.alerts.firstMatch.scrollViews.otherElements.buttons.firstMatch.tap()
        snapshot("4. Vote")

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element(boundBy: 0).tap()
        snapshot("5. Result")
        
    }
    
    @MainActor
    func testConfigScreens() throws {
        // help screens
        app.buttons["questionmark"].tap()
        snapshot("b1")
    }

}
