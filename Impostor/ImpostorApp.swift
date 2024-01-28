//
//  ImpostorApp.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import SwiftUI
import StoreKit

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

@main
struct ImpostorApp: App {
    enum AppState {
        case configuring
        case playing
    }
    
    @State var appState: AppState = .configuring
    
    let storeManager = StoreManager()
    var game: ImpostorGame?
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometryProxy in
                ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
                    .offset(x: appState == .configuring ? 0 : geometryProxy.size.width * 2)
                    .animation(.default, value: appState) // Animate on appState change

                secretWordScene
                    .offset(x: appState != .configuring ? 0 : geometryProxy.size.width * 2)
                    .animation(.default, value: appState) // Animate on appState change
            }
        }
    }
    
    var configurationScene: some View {
        ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
    }
    
    var secretWordScene: some View {
        switch game?.status {
        case .showingSecretWordToPlayerWithIndex(_):
            return Rectangle()
                .background(Color.green)
        default:
            return Rectangle()
                .background(Color.purple)
        }
    }
    
    var stack: some View {
        ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
    }
    
    func startGameWithPlayerCount(_ count: Int) {
        print("Actually starting game with count!", count)
        withAnimation {
            appState = .playing
        }
    }
}
