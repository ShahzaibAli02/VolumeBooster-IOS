//
//  PaywallView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.openURL) var openURL
    @AppStorage(UserDefaultsKeys.isFinishedOnboarding) private var isFinished = false
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.06)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 10) {
                Image(.paywallScreen)
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                VStack(spacing: 24) {
                    makeTitle()
                    VStack {
                        makeDescription()
                        makePurchase()
                    }
                }
                Spacer()
                makeActionView()
                Spacer()
                makePurchaseView()
            }
        }
        
    }
    
    private func makeTitle() -> some View {
        Text("Crank It Up with Confidence")
          .font(
            Font.custom("SF Pro Display", size: 28)
              .weight(.semibold)
          )
          .multilineTextAlignment(.center)
          .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
    
    private func makeDescription() -> some View {
        Text("Volume Soaring, Experience Soaring! 3 Days Free Trial, then 7.99 US$/Week")
          .font(Font.custom("SF Pro Display", size: 17))
          .multilineTextAlignment(.center)
          .foregroundColor(Color(red: 0.24, green: 0.61, blue: 0.19))
    }
    
    private func makePurchase() -> some View {
        Button(action: {
            isFinished = true
        }, label: {
            Text("Or continue with the limited version")
              .font(Font.custom("SF Pro Display", size: 19))
              .underline()
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.24, green: 0.61, blue: 0.19))
        })
    }
    
    private func makeActionView() -> some View {
        ActionView(title: "Continue") {
            InAppPurchaseService.shared.buy(subscription: .weekTrial) {
                isFinished = true
            }
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
}

#Preview {
    PaywallView()
}
