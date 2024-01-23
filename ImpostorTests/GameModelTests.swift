//
//  GameModelTests.swift
//  ImpostorTests
//
//  Created by William Entriken on 2024-01-03.
//

import XCTest
import Impostor

final class GameModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitialState() {
        let model = GameModel.game
        XCTAssert(model.gameStatus == .configure)
    }

    func testCreatGameWithThreePlayers() {
        let model = GameModel.game
        model.startGameWithNumberOfPlayers(3)
    }


}
