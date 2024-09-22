//
//  EqualizerSlider.swift
//  VolumeBooster
//
//  Created by Shahzaib Ali on 16/08/2024.
//

import Foundation
import SwiftUI

struct EqualizerSlider: View {
    let label: String
    @Binding var value: Float
    //    @state var value: Float
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer().frame(height: 10)
            VerticalSlider(
                value: $value,
                range: -12...12,
                step: 0.1,
                onEditingChanged: { editing in
                    onEditingChanged(editing)
                }, sliderType: label == "PR" ? 2:1
            )
            //            .accentColor(.green)
            //            .rotationEffect(.degrees(-90)) // Rotate to make the slider vertical
            //            .frame(width: 100)
            Spacer().frame(height: 10)
            Text(String(format: "%.1f", value))
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
