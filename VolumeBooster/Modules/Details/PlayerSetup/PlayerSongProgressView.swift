//
//  PlayerSongProgressView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import SwiftUI

struct PlayerSongProgressView: View {
    
    @Binding var progressValue: Double
    
    let duration: Double
    var onSeek: ((Double) -> Void)
    
    var body: some View {
        makeBody()
    }
    
    private func makeBody() -> some View {
        ZStack {
            VStack {
                Slider(value: Binding(
                               get: { 
                                   return max(progressValue,0.1) },
                               set: { newValue in
//                                   viewModel.seek(to: newValue)
                                   onSeek(newValue)
                               }
                           ), in: 0...duration, step: 1)
                    .accentColor(.green)
                
                HStack {
                    Text(formatTime(seconds: progressValue))
                      .font(Font.custom("SF Pro Display", size: 15))
                      .kerning(0.374)
                      .foregroundColor(Color(red: 0.63, green: 0.63, blue: 0.63))
                    
                    Spacer()
                    
                    Text( formatTime(seconds:duration))
                      .font(Font.custom("SF Pro Display", size: 15))
                      .kerning(0.374)
                      .foregroundColor(Color(red: 0.63, green: 0.63, blue: 0.63))
                }
            }
        }
    }
    
    func formatTime(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    PlayerSongProgressView(progressValue: .constant(4.011), duration: 20) { newVAl in
        
    }
}
