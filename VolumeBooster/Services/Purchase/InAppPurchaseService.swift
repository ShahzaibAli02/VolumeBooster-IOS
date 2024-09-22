//
//  InAppPurchaseService.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import Foundation
import StoreKit

final class InAppPurchaseService: NSObject {
    
    typealias EmptyCallback = () -> Void
    
    static let shared = InAppPurchaseService()
    
    var purchasedCallback: EmptyCallback?
    let storeObserver = StoreObserver()
    var products: [Product] = []
    var purchasedProductIDs: Set<SubscriptionItemType> = []
    private var updates: Task<Void, Never>? = nil
    
    deinit {
        updates?.cancel()
    }
    
    private let subscriptionIndentifiers: Set<SubscriptionItemType> = Set(SubscriptionItemType.allCases)
    
    private override init() {
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(storeObserver)
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    func buy(subscription: SubscriptionItemType, completion: @escaping () -> Void) {
        
        Task { @MainActor in
            
            let product = self.products.first(where: { $0.id == subscription.rawValue })
            guard let prod = product else {
                return
            }
            
            await buyProduct(prod, completion: completion)
        }
    }
    
    func buyProduct(_ product: Product, completion: @escaping () -> Void) async {
        guard canMakePayments() else {
            return
        }
        
        purchasedCallback = completion
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await self.updatePurchasedProducts()
                debugPrint("User purchased!")
                
                DispatchQueue.main.async { [weak self] in
                    self?.purchasedCallback?()
                }
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                debugPrint("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                debugPrint("User cancelled!")
                break
            @unknown default:
                debugPrint("Failed to purchase the product!")
                break
            }
        } catch {
            debugPrint("Failed to purchase the product!")
        }
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: Array(subscriptionIndentifiers.map { $0.rawValue }))
                .sorted(by: { $0.price > $1.price })
            debugPrint("👻 product \(products.first)")
        } catch {
            debugPrint("Failed to fetch products!")
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result, let item = SubscriptionItemType(rawValue: transaction.productID) else {
                continue
            }
            if transaction.revocationDate == nil {
                
                self.purchasedProductIDs.insert(item)
            } else {
                self.purchasedProductIDs.remove(item)
            }
        }
        
        debugPrint("👻 purchased product \(purchasedProductIDs)")
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            debugPrint(error)
        }
    }
}
