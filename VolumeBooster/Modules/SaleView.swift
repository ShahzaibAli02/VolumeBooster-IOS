//
//  SaleView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct SaleView: View {
    @Environment(\.openURL) var openURL
    @StateObject private var viewModel = SaleVM()
    
    var body: some View {
        ZStack {
            Image(.inAppTrial)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                makeCloseView()
                
                Spacer()
                makeItemsContainer()
                makeTrialToogleView()
                makeActionView()
                makePurchaseView()
                    .padding(.bottom, 50)
            }
            .animation(.easeIn, value: viewModel.isTrialEnabled)
        }
    }
    
    private func makeActionView() -> some View {
        ActionView(title: "Continue") {
            viewModel.buy()
        }
    }
    
    private func makeTextView(title: String, callback: @escaping () -> Void) -> some View {
        Button(action: {
            callback()
        }, label: {
            Text(title)
                .font(Font.custom("SF Pro Display", size: 13))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
        })
    }
    
    private func makePurchaseView() -> some View {
        HStack {
            Spacer()
            makeTextView(title: "Terms of Use") {
                openURL(URL(string: Constants.termsOfUse)!)
            }
            
            Spacer()
            makeTextView(title: "Restore") {
                Task { @MainActor in
                    await InAppPurchaseService.shared.restorePurchases()
                }
            }
            
            Spacer()
            
            makeTextView(title: "Privacy Policy") {
                openURL(URL(string: Constants.privacyPolicy)!)
            }
            
            Spacer()
        }
    }
    
    private func makeTrialToogleView() -> some View {
        HStack {
            Text("Free Trial Enabled")
                .font(
                    Font.custom("SF Pro Display", size: 18)
                        .weight(.semibold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
            
            Spacer()
            
            Toggle(isOn: $viewModel.isTrialEnabled) {
                
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func makeItemsContainer() -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 160)
            .overlay(makeItemsView())
    }
    
    private func makeItemsView() -> some View {
        VStack {
            ForEach(viewModel.items) { item in
                SaleItemView(
                    title: item.title,
                    description: item.description,
                    isSelected: item.isSelected
                ) {
                    viewModel.select(item: item)
                }
            }
        }
    }
    
    private func makeCloseView() -> some View {
        HStack {
            Button(action: {
                
            }, label: {
                Image(.close)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            })
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
    }
}

#Preview {
    SaleView()
}
