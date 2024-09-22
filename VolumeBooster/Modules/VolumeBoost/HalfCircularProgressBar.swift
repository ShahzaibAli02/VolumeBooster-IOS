//
//  HalfCircularProgressBar.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import SwiftUI

struct HalfCircularProgressBar: View {
    var progress: Double
    var color: Color = .blue
    var circleInnerColor: Color = .black
    var backgroundColor: Color = .gray.opacity(0.2)
    let angleDegree = 38.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                
            
                Circle()
                    .trim(from: 0.3, to: 1)
                    .stroke(LinearGradient(gradient: Gradient(colors: [.green,.green,.green ,.red]), startPoint: .bottomLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 35, lineCap: .round ,lineJoin: .round))
                    .rotationEffect(.degrees(angleDegree))
                    .frame(width: geometry.size.width, height: geometry.size.width)
                
                Circle()
                    .trim(from: 0.3, to: 1)
                    .stroke(circleInnerColor, style: StrokeStyle(lineWidth: 33, lineCap: .round))
                    .rotationEffect(.degrees(angleDegree))
                    .frame(width: geometry.size.width, height: geometry.size.width)

                
            
               
                
                // Progress

                Circle()
                    .trim(from:  0.3, to:  0.301 +  (Double(self.progress/100)*(0.7)) )
                    .stroke(LinearGradient(gradient: Gradient(colors: [.green,.green,.green ,.red]), startPoint: .bottomLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(.degrees(angleDegree))
                    .frame(width: geometry.size.width, height: geometry.size.width)

            
            }
        }

    }
}

#Preview {
    HalfCircularProgressBar(progress: 0.4)
}
