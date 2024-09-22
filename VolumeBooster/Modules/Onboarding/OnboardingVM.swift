//
//  OnboardingVM.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import Foundation

final class OnboardingVM: ObservableObject {
    
    @Published var step = 0
    let items = OnboardingItem.allCases
    
    func nextStep() -> OnboardingItem? {
        items[safe: step]
    }
}
