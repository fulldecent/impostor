//
//  ImpostorGameModel.swift
//  Impostor
//
//  Created by William Entriken on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation

@objc enum PlayerRoles : Int {
    case NormalPlayer
    case Impostor
}

@objc enum GameStatus : Int {
    case ShowSecretWords
    case TheImpostorRemains
    case TheImpostorWasDefeated
    case TheImpostorWon
}

class ImpostorGameModel: NSObject {
    static var game = ImpostorGameModel()
    
    private(set) var numberOfPlayers = 0
    private(set) var playerRoles = [PlayerRoles]()
    private(set) var playerEliminated = [Bool]()
    private(set) var gameStatus = GameStatus.ShowSecretWords
    private(set) var playerNumberToStartRound = 0
    private(set) var normalWord = ""
    private(set) var impostorWord = ""
    private(set) var playerWords = [String]()
    
    func startGameWithNumberOfPlayers(numPlayers: Int) {
        var allWordSets = [[String]]()
        let jsonURL = NSBundle.mainBundle().URLForResource("gameWords", withExtension: "json")!
        let jsonData = NSData(contentsOfURL: jsonURL)!
        allWordSets = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [[String]]
        if NSUserDefaults.standardUserDefaults().integerForKey("didIAP") > 0 {
            let moreJsonURL = NSBundle.mainBundle().URLForResource("gameWordsMore", withExtension: "json")!
            let moreJsonData = NSData(contentsOfURL: moreJsonURL)!
            let moreWordSets = try! NSJSONSerialization.JSONObjectWithData(moreJsonData, options: []) as! [[String]]
            allWordSets.appendContentsOf(moreWordSets)
        }
        let chosenWordSet = allWordSets[Int(arc4random_uniform(UInt32(allWordSets.count)))]
        let reverse = arc4random_uniform(2) == 0
        normalWord = chosenWordSet[reverse ? 1 : 0]
        impostorWord = chosenWordSet[reverse ? 0 : 1]
        
        numberOfPlayers = numPlayers
        let impostorIndex = Int(arc4random_uniform(UInt32(numberOfPlayers)))
        for playerNumber in 0 ..< numberOfPlayers {
            if impostorIndex == playerNumber {
                playerRoles.append(.Impostor)
                playerWords.append(self.impostorWord)
            } else {
                playerRoles.append(.NormalPlayer)
                playerWords.append(self.normalWord)
            }
            playerEliminated.append(false)
        }
    }

    func doneShowingSecretWords() {
        gameStatus = .TheImpostorRemains
    }
    
    func eliminatePlayer(playerNumber: Int) {
        assert(playerEliminated[playerNumber] == false)
        playerEliminated[playerNumber] = true
        let remainingPlayerRoles = zip(playerRoles, playerEliminated).flatMap {$1 ? nil : $0}
        let countOfRemainingImpostors = remainingPlayerRoles.reduce(0) {$1 == .Impostor ? $0 + 1 : $0}
        let countOfRemainingNormalPlayers = remainingPlayerRoles.reduce(0) {$1 == .NormalPlayer ? $0 + 1 : $0}
        if countOfRemainingImpostors == 0 {
            gameStatus = .TheImpostorWasDefeated
        } else if countOfRemainingNormalPlayers == 1 {
            gameStatus = .TheImpostorWon
        }
        playerNumberToStartRound = playerNumber
        while playerEliminated[playerNumberToStartRound] {
            playerNumberToStartRound = (playerNumberToStartRound + 1) % numberOfPlayers
        }
    }
}