//
//  Onboarding.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject private var viewModel = OnboardingVM()
    
    var body: some View {
        ZStack {
            if let item = viewModel.nextStep() {
                item
                    .image
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        Spacer()
                        makeActionButton()
                            .padding(.bottom, 50)
                    }
                    .ignoresSafeArea()
                    .animation(.smooth, value: viewModel.step)
            } else {
                makePaywall()
            }
        }
    }
    
    private func makeActionButton() -> some View {
        ActionView(title: "Continue") {
            viewModel.step += 1
        }
    }
    
    private func makePaywall() -> some View {
        PaywallView()
    }
}
