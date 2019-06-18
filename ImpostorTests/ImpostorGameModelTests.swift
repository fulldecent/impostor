//
//  ImpostorGameModel_Tests.swift
//  Impostor
//
//  Created by Full Decent on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import XCTest
@testable import Impostor

class ImpostorGameModelTests: XCTestCase {
    var gameModel: ImpostorGameModel!
    
    override func setUp() {
        super.setUp()
        self.gameModel = ImpostorGameModel.game
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStartGameWithSamePlayers() {
        let numberOfPlayers = 5
        gameModel.startGameWithNumberOfPlayers(numberOfPlayers)
        XCTAssertEqual(gameModel.numberOfPlayers, numberOfPlayers)
    }
    
    func testGameStatusChangedWhenDoneShowingSecretWords() {
        gameModel.startGameWithNumberOfPlayers(10)
        XCTAssertTrue(gameModel.gameStatus == .showSecretWord(0))
        for playerNumber in 0..<10 {
            gameModel.doneShowingSecretWord(playerNumber)
        }
        XCTAssertTrue(gameModel.gameStatus == .theImpostorRemains)
    }
    
    func testElimanateAPlayer() {
        gameModel.startGameWithNumberOfPlayers(10)
        for playerNumber in 0..<10 {
            gameModel.doneShowingSecretWord(playerNumber)
        }
        gameModel.eliminatePlayer(0)
        XCTAssertTrue(gameModel.playerEliminated[0])
        for playerNumber in 1 ..< 10 {
            XCTAssertFalse(gameModel.playerEliminated[playerNumber])
        }
    }
}
