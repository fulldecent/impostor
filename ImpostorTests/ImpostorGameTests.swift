//
//  ImpostorTests.swift
//  ImpostorTests
//
//  Created by William Entriken on 2023-12-31.
//

import XCTest
@testable import Impostor

final class ImpostorGameTests: XCTestCase {
    
    func testNemGame() {
        let numPlayers = 3
        let game = ImpostorGame(numberOfPlayers: numPlayers)
        print(game.players)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
