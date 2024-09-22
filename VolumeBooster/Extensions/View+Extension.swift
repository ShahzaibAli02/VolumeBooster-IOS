//
//  View+Extension.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 16.07.2024.
//

import SwiftUI

extension View {
    
    func inputModifier() -> some View {
        modifier(AppInputViewModifier())
    }
    
    func sharingProgressOverlay(isSharing: Binding<Bool>, progress: Binding<Double>) -> some View {
        self.overlay(
            ZStack {
                if isSharing.wrappedValue {
                    Color.black.opacity(0.4)
                    VStack {
                        ProgressView(value: progress.wrappedValue)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 200)
                        Text("Saving audio : \(Int(progress.wrappedValue * 100))%")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
            }
        )
    }
    
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
