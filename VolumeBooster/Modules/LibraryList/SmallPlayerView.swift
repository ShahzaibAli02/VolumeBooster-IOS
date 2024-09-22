//
//  SmallPlayerView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 18.07.2024.
//

import SwiftUI

struct SmallPlayerView: View {
    
    var progress: Double
    let item: LibraryListItem
    let isPlaying: Bool
    let onTapPlay: () -> Void
    let onTapClose: () -> Void
    let onTapPlayer: () -> Void
    
    var body: some View {
        makeBody()
    }
    
    private func makeBody() -> some View {
        VStack(alignment: .center, spacing: 10) {
            ProgressBar(value: progress)
                .frame(height: 2)
                .padding(.horizontal)
            
            HStack {
                HStack {
                    makeImag()
                    makeText()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onTapPlayer()
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button {
                        onTapPlay()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button {
                        onTapClose()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.24, green: 0.61, blue: 0.19).opacity(0.24), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.08, green: 0.21, blue: 0.06).opacity(0.24), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 1),
                endPoint: UnitPoint(x: 0.5, y: 0.48)
            )
        )
    }
    
    private func makeText() -> some View {
        Text(item.title)
            .font(Font.custom("SF Pro Display", size: 17))
            .kerning(0.374)
            .foregroundColor(.white)
    }
    
    private func makeImag() -> some View {
        Image(.songImg)
    }
}

#Preview {
    SmallPlayerView(progress: 5, item: .stub, isPlaying: false, onTapPlay: {}, onTapClose: {}, onTapPlayer: {})
}


struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.green)
            }
            .cornerRadius(45.0)
        }
    }
}
