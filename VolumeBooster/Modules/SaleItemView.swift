//
//  SaleItemView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

struct SaleItemView: View {
    
    let title: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        makeBody()
            .animation(.easeOut, value: isSelected)
            .onTapGesture {
                onTap()
            }
    }
    
    private func makeBody() -> some View {
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading,  spacing: 6) {
                    if title.isEmpty == false {
                        titleView()
                    }
                    
                    descriptionView()
                    
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                Spacer()
                
                makeImage()
                    .padding(.trailing)
            }
            .background {
                selectedBg()
            }
            .cornerRadius(12)
            .overlay(
                borderRectangle()
            )
        }
       
    }
    
    private func noSelectedBg() -> some View {
        Color(.bg)
    }
    
    @ViewBuilder
    private func selectedBg() -> some View {
        if isSelected {
            LinearGradient(
              stops: [
                Gradient.Stop(color: Color(red: 0.52, green: 0.86, blue: 0.46).opacity(0.12), location: 0.00),
                Gradient.Stop(color: Color(red: 0.23, green: 0.52, blue: 0.18).opacity(0.12), location: 1.00),
              ],
              startPoint: UnitPoint(x: 0.99, y: 0.5),
              endPoint: UnitPoint(x: 0, y: 0.5)
            )
        } else {
            noSelectedBg()
        }
    }
    
    private func borderRectangle() -> some View {
        RoundedRectangle(cornerRadius: 12)
          .inset(by: 0.5)
          .stroke(Color(red: 0.24, green: 0.61, blue: 0.19), lineWidth: 1)
    }
    
    private func titleView() -> some View {
        Text(title)
          .font(Font.custom("SF Pro Display", size: 13))
          .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
    
    private func descriptionView() -> some View {
        Text(description)
          .font(Font.custom("SF Pro Display", size: 17))
          .foregroundColor(Color(red: 0.24, green: 0.61, blue: 0.19))
    }
    
    private func makeImage() -> some View {
        ZStack {
            Image(isSelected ? "selectDone" : "selectEmpty")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    SaleItemView(title: "Get 3-days Free Trial for", description: "7.99 US$/Week", isSelected: false) {}
}
