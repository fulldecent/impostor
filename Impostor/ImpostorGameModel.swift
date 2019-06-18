//
//  ImpostorGameModel.swift
//  Impostor
//
//  Created by William Entriken on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation

enum PlayerRoles : Int {
    case normalPlayer
    case impostor
}

enum GameStatus : Int {
    case showSecretWords
    case theImpostorRemains
    case theImpostorWasDefeated
    case theImpostorWon
}

class ImpostorGameModel: NSObject {
    static var game = ImpostorGameModel()
    
    fileprivate(set) var numberOfPlayers = 0
    fileprivate(set) var playerRoles = [PlayerRoles]()
    fileprivate(set) var playerEliminated = [Bool]()
    fileprivate(set) var gameStatus = GameStatus.showSecretWords
    fileprivate(set) var playerNumberToStartRound = 0
    fileprivate(set) var normalWord = ""
    fileprivate(set) var impostorWord = ""
    fileprivate(set) var playerWords = [String]()
    
    func startGameWithNumberOfPlayers(_ numPlayers: Int) {
        var allWordSets = [[String]]()
        let jsonURL = Bundle.main.url(forResource: "gameWords", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        allWordSets = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String]]
        if UserDefaults.standard.integer(forKey: "didIAP") > 0 {
            let moreJsonURL = Bundle.main.url(forResource: "gameWordsMore", withExtension: "json")!
            let moreJsonData = try! Data(contentsOf: moreJsonURL)
            let moreWordSets = try! JSONSerialization.jsonObject(with: moreJsonData, options: []) as! [[String]]
            allWordSets.append(contentsOf: moreWordSets)
        }
        let chosenWordSet = allWordSets.randomElement()!
        normalWord = chosenWordSet[0]
        impostorWord = chosenWordSet[1]
        if Bool.random() == true {
            swap(&normalWord, &impostorWord)
        }
        numberOfPlayers = numPlayers
        playerRoles = [PlayerRoles](repeating: .normalPlayer, count: numberOfPlayers)
        playerWords = [String](repeating: self.normalWord, count: numberOfPlayers)
        playerEliminated = [Bool](repeating: false, count: numberOfPlayers)
        let impostorIndex = Int.random(in: 0..<numberOfPlayers)
        playerRoles[impostorIndex] = .impostor
        playerWords[impostorIndex] = self.impostorWord
        playerNumberToStartRound = Int.random(in: 0..<numberOfPlayers)
        gameStatus = .showSecretWords
    }

    func doneShowingSecretWords() {
        gameStatus = .theImpostorRemains
    }
    
    func eliminatePlayer(_ playerNumber: Int) {
        assert(playerEliminated[playerNumber] == false)
        playerEliminated[playerNumber] = true
        
        let remainingPlayerRoles = zip(playerRoles, playerEliminated).compactMap {$1 ? nil : $0}
        let countOfRemainingImpostors = remainingPlayerRoles.filter({$0 == .impostor}).count
        let countOfRemainingNormalPlayers = remainingPlayerRoles.filter({$0 == .normalPlayer}).count
        if countOfRemainingImpostors == 0 {
            gameStatus = .theImpostorWasDefeated
        } else if countOfRemainingNormalPlayers == 1 {
            gameStatus = .theImpostorWon
        }
        playerNumberToStartRound = playerNumber
        while playerEliminated[playerNumberToStartRound] {
            playerNumberToStartRound = (playerNumberToStartRound + 1) % numberOfPlayers
        }
    }
}
