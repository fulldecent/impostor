//
//  ImpostorGame.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import Foundation

struct ImpostorGame {
    private(set) var players: [Player]
    private(set) var status: Status
    
    init(numberOfPlayers: Int) {
        let numberOfPlayers = numberOfPlayers.clamped(to: 3...12)
        let impostorIndex = Int.random(in: 0..<numberOfPlayers)
        let wordPair = Self.allWordPairs().randomElement()!
        let (normalWord, impostorWord) = Bool.random()
        ? wordPair
        : (wordPair.1, wordPair.0)
        
        players = (0..<numberOfPlayers).map({ playerIndex in
            Player(
                role: playerIndex == impostorIndex ? .impostor : .normal,
                word: playerIndex == impostorIndex ? impostorWord : normalWord
            )
        })
        
        status = .showingSecretWordToPlayerWithIndex(0)
    }
    
    mutating func finishedShowingSecretWordToPlayer() {
        switch status {
        case .showingSecretWordToPlayerWithIndex(let playerIndex):
            if players.indices.contains(playerIndex + 1) {
                status = .showingSecretWordToPlayerWithIndex(playerIndex + 1)
            } else {
                let randomPlayerIndex = players.indices.randomElement()!
                status = .votingStartingWithPlayerWithIndex(randomPlayerIndex)
            }
        default:
            break
        }
    }
    
    mutating func eliminatePlayerWithIndex(_ playerIndex: Int) {
        assert(!players[playerIndex].eliminated)
        
        players[playerIndex].eliminated = true
        let remaining = players.filter{ !$0.eliminated }
        let numImpostors = remaining.filter{ $0.role == .impostor }.count
        let numNormal = remaining.count - numImpostors
        
        // Check for end game conditions
        if numImpostors == 0 {
            status = .impostorDefeated
            return
        } else if numNormal == 1 {
            status = .impostorWon
            return
        }
        
        // Continue with first non-eliminated player after the voted player
        var nextPlayerIndex = (playerIndex + 1) % players.count
        while players[nextPlayerIndex].eliminated {
            nextPlayerIndex = (nextPlayerIndex + 1) % players.count
        }
        status = .votingStartingWithPlayerWithIndex(nextPlayerIndex)
    }

    struct Player: Equatable {
        enum Role {
            case normal
            case impostor
        }
        
        let role: Role
        let word: String
        var eliminated: Bool = false
    }
    
    enum Status: Equatable {
        case showingSecretWordToPlayerWithIndex(_: Int)
        case votingStartingWithPlayerWithIndex(_: Int)
        case impostorWon
        case impostorDefeated
    }

    //MARK: word lists
    private static let freeWordPairs: [(String, String)] = {
        let jsonURL = Bundle.main.url(forResource: "gameWords", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        let jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String]]
        return jsonArray.map { ($0[0], $0[1]) }
    }()
    
    private static let paidWordPairs: [(String, String)] = {
        let jsonURL = Bundle.main.url(forResource: "gameWordsMore", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        let jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String]]
        return jsonArray.map { ($0[0], $0[1]) }
    }()

    private static func allWordPairs() -> [(String, String)] {
        let didIAP = UserDefaults.standard.integer(forKey: "didIAP") > 0
        return didIAP ? Self.freeWordPairs + Self.paidWordPairs : Self.freeWordPairs
    }
}

fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
