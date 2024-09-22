//
//  StoreObserver.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import Foundation
import StoreKit

final class StoreObserver: NSObject, SKPaymentTransactionObserver {
    
    static let shared = StoreObserver()
    
    var transactionState: SKPaymentTransactionState?
    
    override init() {
        super.init()
    }

    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
               debugPrint("👻 purchasing")
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                debugPrint("👻 purchased")
                transactionState = .purchased
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                debugPrint("👻 restored")
                transactionState = .restored
            case .failed, .deferred:
                let transactionError =  transaction.error.debugDescription
                debugPrint("👻 Payment Queue Error: \(transactionError)")
                queue.finishTransaction(transaction)
                debugPrint("👻 failed, deferred")
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        true
    }
}
