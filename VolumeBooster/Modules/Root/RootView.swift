//
//  RootView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct RootView: View {
    
    @AppStorage(UserDefaultsKeys.isFinishedOnboarding)
    private var isFinished = false
    
    var body: some View {
        makeBody()
    }
    
    private func makeBody() -> some View {
        ZStack {
            if isFinished {
                LibraryListView()
            } else {
                OnboardingView()
            }
        }
        .onAppear(perform: {
            Task {
                await InAppPurchaseService.shared.loadProducts()
            }
            
        })
        .animation(.easeOut, value: isFinished)
    }
}

#Preview {
    RootView()
}
