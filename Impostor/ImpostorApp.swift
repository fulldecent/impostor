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
    @State private var game: ImpostorGame?
    let storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if game != nil {
                    switch game!.status {
                    case .showingSecretWordToPlayerWithIndex(let index):
                        ShowSecretWordScene(
                            playerName: "Player \(index+1)",
                            secretWord: game!.players[index].word,
                            image: .constant(Image("4")),     // ??$PlayerImages.shared.image(forPlayerIndex: index),
                            shouldAttemptTakePhoto: false,
                            onDoneViewingSecretWord: { game!.finishedShowingSecretWordToPlayer() },
                            onAbortGame: { game = nil }
                        )
                        .id(index)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    case .votingStartingWithPlayerWithIndex(let index):
                        Text("hi")
                    case .impostorWon:
                        Text("hi")
                    case .impostorDefeated:
                        Text("hi")
                    }
                } else {
                    ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: game)
        }
    }
    
    func startGameWithPlayerCount(_ count: Int) {
        game = .init(numberOfPlayers: count)
    }
}

fileprivate extension AnyTransition {
    static var slide: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
        let removal = AnyTransition.move(edge: .leading)
        return .asymmetric(insertion: insertion, removal: removal)
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
