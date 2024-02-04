//
//  ImpostorApp.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

// FIXME: go through all api ta make stuff private when needed

import SwiftUI
import StoreKit

@main
struct ImpostorApp: App {
    let storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ImpostorAppView()
        }
    }
    
}

fileprivate struct ImpostorAppView: View {
    @State private var game: ImpostorGame?
    @State private var dummyVariableToUpdatePlayerPhotos = 0
    
    var body: some View {
        ZStack {
            switch game?.status {
            case nil:
                ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            case .showingSecretWordToCurrentPlayer:
                SecretWordScene(
                    playerIndex: game!.currentPlayerIndex,
                    secretWord: game!.players[game!.currentPlayerIndex].word,
                    close: { game!.finishedShowingSecretWordToPlayer() },
                    abortGame: { self.game = nil }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                .id(game!.currentPlayerIndex)
            case .votingStartingWithCurrentPlayer:
                VotingScene(
                    players: game!.players,
                    currentPlayerIndex: game!.currentPlayerIndex,
                    imageForPlayerIndex: {
                        PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage
                    },
                    votedPlayer: {
                        AudioManager.shared.playSoundEffect(named: "eliminate")
                        game!.eliminatePlayerWithIndex($0)
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                .id(game!.currentPlayerIndex)

                //                     VotingScene(
            //players: game?.players, imageForPlayerIndex: <#T##(Int) -> (Image)#>)
            case .impostorWon:
                Text("won")
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    .id(77)
                // ResultsScene(players: <#T##[ImpostorGame.Player]#>, status: <#T##ImpostorGame.Status#>, imageForPlayerIndex: <#T##(Int) -> (Image)#>, aView: <#T##Text#>)
            case .impostorDefeated:
                Text("defeated")
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    .id(88)
                // ResultsScene
            }
        }
        .animation(.easeInOut, value: game)
    }
    
    func startGameWithPlayerCount(_ count: Int) {
        game = .init(numberOfPlayers: count)
    }
}

class StoreManager: NSObject, SKPaymentTransactionObserver {
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        handleTransactions(transactions)
    }

    func checkPurchases() {
        let transactions = SKPaymentQueue.default().transactions
        handleTransactions(transactions)
    }

    private func handleTransactions(_ transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                // Handle the completed transaction, deliver the content
                SKPaymentQueue.default().finishTransaction(transaction)

                // Update UserDefaults or similar to record the purchase
                let defaults = UserDefaults.standard
                defaults.set(1, forKey: "didIAP")
                defaults.synchronize()

                print("Transaction completed: \(transaction)")
            case .failed:
                // Handle failed transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}

#Preview {
    ImpostorAppView()
}
