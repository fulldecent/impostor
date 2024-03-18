//
//  StoreManager.swift
//  Impostor
//
//  Created by William Entriken on 2024-02-09.
//

import Foundation
import StoreKit

class StoreManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    @Published var isPurchased: Bool
    private let productIdentifier = "words0001"
    private let userDefaultsKey = "didIAP"
    
    static let shared = StoreManager()
    
    private override init() {
        isPurchased = UserDefaults.standard.bool(forKey: userDefaultsKey)
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func purchase() {
        if isPurchased { return } // Already done
        
        let request = SKProductsRequest(productIdentifiers: Set([productIdentifier]))
        request.delegate = self
        request.start()
    }
    
    // SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    self.isPurchased = true
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
