//
//  PlayerSetupView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 16.07.2024.
//

import SwiftUI

struct PlayerSetupView: View {
    
    @StateObject private var viewModel = PlayerSetupViewModel()
    
    let model: PlayerSetupModel
    let onTap: (PlayerSetupType) -> ()
    
    var body: some View {
        makeBody()
    }
    
    private func makeBody() -> some View {
        HStack(spacing: 15) {
            ForEach(viewModel.items) { item in
                Spacer()
                makeBtn(item: item)
                Spacer()
            }
        }
        .animation(.easeInOut, value: viewModel.selectedType)
        .frame(height: 50)
    }
    
    private func makeBtn(item: PlayerSetupType) -> some View {
        Button(action: {
            viewModel.didSelect(item: item)
            onTap(item)
        }, label: {
            VStack {
                circleShape(item: item)
                    .overlay {
                        makeImg(item: item)
                            
                    }
                makeTextView(item: item)
            }
        })
    }
    
    private func makeTextView(item: PlayerSetupType) -> some View {
        Text(item.title)
          .font(Font.custom("SF Pro Display", size: 11))
          .kerning(0.374)
          .multilineTextAlignment(.center)
          .foregroundColor(viewModel.selectedType == item ? Color(red: 0.24, green: 0.61, blue: 0.19) : Color(red: 0.97, green: 0.97, blue: 0.97))
    }
    
    @ViewBuilder
    private func makeImg(item: PlayerSetupType) -> some View {
        if model.hasPremium {
            if item == .bass {
                Image(.corona)
            } else {
                item.icon
            }
        } else {
            item.icon
        }
    }
    
    private func circleShape(item: PlayerSetupType) -> some View {
        Circle()
            .stroke(viewModel.selectedType == item ? Color(red: 0.24, green: 0.61, blue: 0.19) : Color(red: 0.09, green: 0.16, blue: 0.08), lineWidth: 1)
    }
}

final class PlayerSetupViewModel: ObservableObject {
    
    @Published var selectedType: PlayerSetupType?
    @Published var items: [PlayerSetupType] = PlayerSetupType.allCases
    
    func didSelect(item: PlayerSetupType) {
        guard item == selectedType else {
            selectedType = item
            return
        }
        selectedType = nil
    }
}

struct PlayerSetupModel: Identifiable {
    
    let id: String = UUID().uuidString
    
    let hasPremium: Bool
}

enum PlayerSetupType: String, CaseIterable, Identifiable {
    case volumeBoost
    case bass
    case equilaizer
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .volumeBoost:
            return "Volume Boost"
        case .bass:
            return "Bass Boost"
        case .equilaizer:
            return "Equalizer"
        }
    }
    
    var icon: Image {
        switch self {
        case .volumeBoost:
            return Image(.boostImg)
            
        case .bass:
            return Image(.bassImg)
            
        case .equilaizer:
            return Image(.filterImg)
        }
    }
}

#Preview {
    PlayerSetupView(model: .init(hasPremium: true), onTap: { _ in })
}
