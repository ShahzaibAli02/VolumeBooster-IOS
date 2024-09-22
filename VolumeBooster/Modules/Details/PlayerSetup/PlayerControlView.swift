//
//  PlayerControlView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 16.07.2024.
//

import SwiftUI

struct PlayerControlView: View {
    
//    @StateObject private var viewModel = PlayerControlViewModel()
    
    @Binding var isPlaying : Bool
    @Binding var hasNext : Bool
    @Binding var hasPrev : Bool
    
    
    let onTap: (PlayerControlType) -> Void
//    @Published var items: [PlayerControlType] = PlayerControlType.allCases
    
    var body: some View {
        makeBody()
            .animation(.easeInOut, value: isPlaying)
    }
    
    private func makeBody() -> some View {
        VStack {
            HStack(spacing: 30) {
                makeButton(item: PlayerControlType.skipLeft).opacity( hasPrev ? 1 : 0.4)
                makeButton(item: isPlaying ? PlayerControlType.play : PlayerControlType.pause )
                makeButton(item: PlayerControlType.skipRight).opacity( hasNext ? 1 : 0.4)
            }
//            HStack(spacing: 5) {
//                
//                makeResetVolumeButton()
//                
//                Slider(value: $viewModel.currentVolume, in: 0...100, step: 1)
//                    .accentColor(.green)
//                
//                makeAddVolumeButton()
//            }
//            .frame(height: 40)
        }
    }
    
    private func makeResetVolumeButton() -> some View {
        Button(action: {
            
        }, label: {
            Image(.songImgMinus)
                .padding()
        })
    }
    
    private func makeAddVolumeButton() -> some View {
        Button(action: {
            
        }, label: {
            Image(.songImgPlus)
                .padding()
        })
    }
    
    private func makeButton(item: PlayerControlType) -> some View {
        
        Button(action: {
            onTap(item)
        }, label: {
            makeImg(item: item)
        })
    }
    
    @ViewBuilder
    private func makeImg(item: PlayerControlType) -> some View {
        item.icon
    }
}
//
//final class PlayerControlViewModel: ObservableObject {
//    @Published var isPlaying = false
//    @Published var currentVolume: Double = 0
//    
//    @Published var items: [PlayerControlType] = PlayerControlType.allCases
//    
//}

enum PlayerControlType: String, CaseIterable, Identifiable {
    case skipLeft, play,pause, skipRight
    
    var id: String { rawValue }
    
    var icon: Image {
        switch self {
        case .skipLeft:
            return Image(.skipLeft)
        case .play:
            return Image(.circlePause)
        case .pause:
            return Image(.circlePlay)
        case .skipRight:
            return Image(.skipRight)
        }
    }
    
}

//#Preview {
//    PlayerControlView(isPlaying:Binding(
//        get: { true },
//        set: { newValue in
////                                   viewModel.seek(to: newValue)
////            onSeek(newValue)
//        }
//    ),onTap: { _ in })
//}


