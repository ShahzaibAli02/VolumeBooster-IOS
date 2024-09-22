//
//  AppInputModifier.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 16.07.2024.
//

import SwiftUI

struct AppInputViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.red)
            .background {
                RoundedRectangle(cornerRadius: AppConstants.Button.cornerRadius)
                    .foregroundColor(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppConstants.Button.cornerRadius)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.brown)
                    }
            }
    }
}

struct AppConstants {
    
    struct Button {
        static let cornerRadius: CGFloat = 12.0
        static let height: CGFloat = 44
        static let fontSize: CGFloat = 14
    }
    
    struct Global {
        static let shadowRadius: CGFloat = 12
    }
    
    struct URLs {
        
    }
    
    struct SDKKeys {
    }
}

