//
//  OnboardingItem.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

enum OnboardingItem: CaseIterable {
    case onboarding1, onboarding2, onboarding3, onboarding4, onboarding5
    
    var image: Image {
        switch self {
        case .onboarding1:
            return Image(.onboarding1)
        case .onboarding2:
            return Image(.onboarding2)
        case .onboarding3:
            return Image(.onboarding3)
        case .onboarding4:
            return Image(.onboarding4)
        case .onboarding5:
            return Image(.onboarding5)
        }
    }
}
