//
//  ImpostorGame.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import Foundation

struct ImpostorGame: Equatable, Hashable {
    private(set) var players: [Player]
    private(set) var status: Status
    
    init(numberOfPlayers: Int) {
        let numberOfPlayers = numberOfPlayers.clamped(to: 3...12)
        let impostorIndex = Int.random(in: 0..<numberOfPlayers)
        let (normalWord, impostorWord) = Self.randomWordPair()
        
        players = (0..<numberOfPlayers).map({ playerIndex in
            Player(
                role: playerIndex == impostorIndex ? .impostor : .normal,
                word: playerIndex == impostorIndex ? impostorWord : normalWord
            )
        })
        
        status = .showingSecretWord(playerIndex: 0)
    }
    
    mutating func finishedShowingSecretWord(withPlayerIndex playerIndex: Int) {
        guard status == .showingSecretWord(playerIndex: playerIndex) else { return }
        
        if players.indices.contains(playerIndex + 1) {
            status = .showingSecretWord(playerIndex: playerIndex + 1)
        } else {
            status = .voting(round: 1, startingPlayerIndex: players.indices.randomElement()!)
        }
    }
    
    mutating func eliminatePlayerWithIndex(_ playerIndex: Int) {
        guard case .voting(let votingRound, _) = status else { return }
        guard !players[playerIndex].eliminated else { return }
        
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
        
        status = .voting(round: votingRound + 1, startingPlayerIndex: nextPlayerIndex)
    }

    struct Player: Equatable, Hashable, Identifiable {
        enum Role {
            case normal
            case impostor
        }
        
        let role: Role
        let word: String
        let id = UUID()
        var eliminated: Bool = false
    }
    
    enum Status: Equatable, Hashable {
        case showingSecretWord(playerIndex: Int)
        case voting(round: Int, startingPlayerIndex: Int)
        case impostorWon
        case impostorDefeated
    }

    //MARK: word lists
    
    // Data file is a JSON array of sets of similar words
    
    private static let allWordSets: [[String]] = {
        let jsonURL = Bundle.main.url(forResource: "gameWords", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String]]
    }()
    
    private static func randomWordPair() -> (String, String) {
        let didIAP = UserDefaults.standard.integer(forKey: "didIAP") > 0
        let wordSet = didIAP
        ? allWordSets.randomElement()!
        : allWordSets[0..<45].randomElement()!
        let shuffledSet = wordSet.shuffled()
        return (shuffledSet[0], shuffledSet[1])
    }
}

fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
