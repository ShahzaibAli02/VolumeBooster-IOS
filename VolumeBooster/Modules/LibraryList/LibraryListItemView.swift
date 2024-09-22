//
//  LibraryListItemView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 15.07.2024.
//

import SwiftUI

struct LibraryListItemView: View {
    
    enum ActionStyle {
        case  rename, delete
    }
    
    let item: LibraryListItem
    let onTap: () -> Void
    let onTapMore: (ActionStyle) -> Void
    
    var gradients: [Gradient.Stop] {
        if item.isSelected {
            return [Gradient.Stop(color: Color(red: 0.24, green: 0.61, blue: 0.19).opacity(0.28), location: 0.00),
            Gradient.Stop(color: Color(red: 0.18, green: 0.45, blue: 0.14).opacity(0.28), location: 0.40),
            Gradient.Stop(color: Color(red: 0.08, green: 0.21, blue: 0.06).opacity(0), location: 1.00)
            ]
        } else {
            return [.init(color: .black, location: 1)]
        }
    }
    
    var body: some View {
        
        makeGradientView()
            .overlay(alignment: .leading) {
                makeContentView()
            }
            .animation(.easeIn, value: item.isSelected)
    }
    
    private func makeGradientView() -> some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                stops: gradients,
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 0.89, y: 0.5)
            )
            .cornerRadius(5)
        }
    }
    
    private func makeContentView() -> some View {
        HStack {
            
            HStack {
                makeImg()
                
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.white)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            Spacer()
            
            makeMoreButton()
        }
    }
    
    private func makeMoreButton() -> some View {
        Menu {
            Button(role: .destructive) {
                onTapMore(.delete)
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
//            Button {
//                onTapMore(.share)
//            } label: {
//                HStack {
//                    Image(systemName: "square.and.arrow.up")
//                    Text("Share")
//                }
//            }
//            Button {
//                onTapMore(.download)
//            } label: {
//                HStack {
//                    Image(systemName: "square.and.arrow.down")
//                    Text("Download")
//                }
//            }
            
            Button {
                onTapMore(.rename)
            } label: {
                HStack {
                    Image(systemName: "pencil.line")
                    Text("Rename")
                }
            }
        } label: {
            Image(.moreImg)
                .foregroundColor(.white)
        }
    }
    
    private func makeImg() -> some View {
        Image(item.isSelected ? "playSongImg" : "songImg")
            .foregroundColor(.white)
    }
}

#Preview {
    LibraryListItemView(item: .init(title: "gdfdfgd", isSelected: false, audioFileURL: "", id: "1"), onTap: {}, onTapMore: { _ in })
}
