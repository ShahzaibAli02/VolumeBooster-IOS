//
//  SaleVM.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import Foundation

final class SaleVM: ObservableObject {
    
    @Published var isTrialEnabled = false
    
    @Published var trialElems: [SaleItemModel] = []
    @Published var elems: [SaleItemModel] = []
    
    var items: [SaleItemModel] { isTrialEnabled ? trialElems : elems }
    
    init() {
        presetArray()
    }
    
    func buy() {
        guard let selectedValue = items.first(where: { $0.isSelected }) else {
            return
        }
        
        InAppPurchaseService.shared.buy(subscription: selectedValue.saleType) {
            
        }
    }
    
    func select(item: SaleItemModel) {
        
        guard let selectedValue = items.first(where: { $0.isSelected }) else {
            handleSelect(item: item)
            return
        }
        
        handleSelect(item: selectedValue)
        handleSelect(item: item)
    }
    
    private func handleSelect(item: SaleItemModel) {
        if isTrialEnabled {
            update(item: item, sourceArray: &trialElems, isSelected: !item.isSelected)
        } else {
            update(item: item, sourceArray: &elems, isSelected: !item.isSelected)
        }
    }
    
    
    private func handleDeselect(item: SaleItemModel) {
        if isTrialEnabled {
            update(item: item, sourceArray: &trialElems, isSelected: false)
        } else {
            update(item: item, sourceArray: &elems, isSelected: false)
        }
    }
    
    private func update(item: SaleItemModel, sourceArray: inout [SaleItemModel], isSelected: Bool) {
        if let i = sourceArray.firstIndex(of: item) {
            print("update value: \(i) + \(item)")
            sourceArray[i] = .init(saleType: item.saleType, title: item.title, description: item.description, isSelected: isSelected)
        }
    }
    
    private func presetArray() {
        trialElems = [
            .init(saleType: .weekTrial, title: "Get 3-days Free Trial for", description: "7.99 US$/Week", isSelected: false),
            .init(saleType: .yearTrial, title: "Get 3-days Free Trial for", description: "40.99 US$/Year", isSelected: false)
        ]
        
        elems = [
            .init(saleType: .week, title: "", description: "6.99 US$/Week", isSelected: false),
            .init(saleType: .year, title: "", description: "39.99 US$/Year", isSelected: false)
        ]
    }
}

struct SaleItemModel: Hashable, Identifiable {
    let saleType: SubscriptionItemType
    let title: String
    let description: String
    var isSelected: Bool
    
    var id: String { saleType.rawValue }
}
