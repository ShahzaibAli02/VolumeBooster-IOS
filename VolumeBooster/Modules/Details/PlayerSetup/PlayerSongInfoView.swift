//
//  PlayerSongInfoView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import SwiftUI

struct PlayerSongInfoView: View {
    
    let isCollapsed: Bool
    let songName: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            .overlay {
                makeOverlay()
            }
        }
        .animation(.easeInOut, value: isCollapsed)
    }
    
    @ViewBuilder
    private func makeOverlay() -> some View {
        if isCollapsed {
            makeCollapsedOverlay()
        } else {
            makeOppenedOverlay()
        }
    }
    
    private func makeOppenedOverlay() -> some View {
        VStack(spacing: 30) {
            Image(.noteEmpty)
            
            makeText()
        }
    }
    
    private func makeCollapsedOverlay() -> some View {
        VStack {
            makeText()
            Spacer()
        }
    }
    private func makeText() -> some View {
        Text(songName)
          .font(Font.custom("SF Pro Display", size: 26))
          .kerning(0.374)
          .foregroundColor(.white)
    }
}

#Preview {
    PlayerSongInfoView(isCollapsed: false, songName: "Hello")
}
