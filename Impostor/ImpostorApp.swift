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
            if let activeGame = game {
                switch activeGame.status {
                case .showingSecretWordToPlayerWithIndex(let index):
                    SecretWordScene(
                        playerIndex: index,
                        secretWord: activeGame.players[index].word,
                        close: { game!.finishedShowingSecretWordToPlayer() },
                        abortGame: { game = nil }
                    )
                    .id("\(index)")
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
