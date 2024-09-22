//
//  ActionView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct ActionView: View {
    
    let title: String
    let callBack: () -> Void
    
    @State private var scaleEffect: CGFloat = 1
        
    var body: some View {
        ZStack {
            Image(.buttonBg)
                .overlay(alignment: .center) {
                    Button(action: {
                        scaleEffect = 0.98
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scaleEffect = 1.0
                            callBack()
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Text(title)
                              .font(
                                Font.custom("SF Pro Display", size: 17)
                                  .weight(.bold)
                              )
                              .multilineTextAlignment(.center)
                              .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    })
                }
                .scaleEffect(CGSize(width: scaleEffect, height: scaleEffect))
                .animation(.easeIn, value: scaleEffect)
        }
    }
}

#Preview {
    ActionView(title: "Continue") {}
}
