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
    var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            TmpView()
            /*
            ResultsScene(
                players: [
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .normal, word: "Normal word"),
                    .init(role: .impostor, word: "Really long impostor word")
                ],
                status: .impostorDefeated
            )
             */

//            ConfigurationScene()
//            ContentView()
//                .onAppear(perform: storeManager.checkPurchases)
        }
    }
}
