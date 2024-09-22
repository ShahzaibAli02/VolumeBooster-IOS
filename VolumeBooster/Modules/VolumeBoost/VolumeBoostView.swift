//
//  VolumeBoostView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 08.07.2024.
//

import Foundation
import SwiftUI

struct VolumeBoostView: View {
    
    
    //Actual variable to store Volume Percentage
    @Binding var actualVolume: Int
    
    //To control angle of Slider by default its 65 means (volumeBoost / 100 * 360) which 234 Degree
    @Binding  var volumeBoost: Double

 
    //Number of small circls around big circle
    private let ROUND_INDICATOR_COUNT = 13
    
    //How many last round indicator needs to be red
    private let LAST_ROUND_INDICATOR_COUNT_RED = 3
    
    private let CIRCLE_WIDTH = 250.0
    private let CIRCLE_HEIGHT = 250.0

    
    var body: some View {
        ZStack {
            backgroundColor
            VStack(spacing: 20) {
                titleView
                percentageView
                Spacer().frame(height: 30)
                circularSlider
                minMaxLabels
            }
        }
    }
    
    private var backgroundColor: some View {
        Color.clear.edgesIgnoringSafeArea(.all)
    }
    
    private var titleView: some View {
        Text("Volume Boost")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    private var percentageView: some View {
        Text("\(Int(actualVolume))%")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    private var circularSlider: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 4)
                .frame(width: CIRCLE_WIDTH, height: CIRCLE_HEIGHT)
            
            indicatorDots
            
            sliderKnob
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged(handleDrag)
        )
    }
    
    private var indicatorDots: some View {
        ForEach(0..<ROUND_INDICATOR_COUNT, id: \.self) { index in
            Circle()
                .fill(dotColor(for: index))
                .frame(width: 15, height: 15)
                .offset(y: -150)
                .rotationEffect(.degrees((-120+(Double(index)*20)))
                )
        }
    }
    private func dotColor(for index: Int) -> Color {
        let mVal1 : Double = (100.0 / Double(ROUND_INDICATOR_COUNT))
        let threshHold = Int(Double(actualVolume) / mVal1  + 1)
        if index < threshHold {
            if index > (ROUND_INDICATOR_COUNT-LAST_ROUND_INDICATOR_COUNT_RED)
            {
                return .red
            }
            return .green
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var sliderKnob: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 8, height: 20)
            .offset(y: -100)
            .rotationEffect(.degrees(
                volumeBoost / 100 * 360))
    }
    
    private var minMaxLabels: some View {
        HStack(spacing: 180) {
            speakerLabel(imageName: "speaker.wave.1.fill", text: "Min",color: Color.green)
                .onTapGesture {
            
                    updateVolume(newVolume: 66.0)
                }
            speakerLabel(imageName: "speaker.wave.3.fill", text: "Max",color: Color.red).onTapGesture {
        
                updateVolume(newVolume:34.49246002991625)
            }
        }
    }
    
    private func updateVolume(newVolume:CGFloat) {
        volumeBoost = newVolume
        actualVolume = actualVolume(for:(volumeBoost / 100 * 360 ))

    }
    
    private func speakerLabel(imageName: String, text: String,color:Color) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 20))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
            Spacer().frame(width:10)
            Image(systemName: imageName)
                .resizable()
                 .frame(width: 30, height: 30)
                .foregroundColor(color)
         
        }
    }
    
    private func handleDrag(value: DragGesture.Value) {
        let center = CGPoint(x: 125, y: 125)
        let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
        let angle = atan2(vector.dy, vector.dx) + .pi/2
        let fixedAngle = angle < 0 ? angle + 2 * .pi : angle
        
        let newVolume = min(max(fixedAngle / (2 * .pi) * 100, 0), 100)
           
        if (34...66).contains(newVolume){
            return
        }
        updateVolume(newVolume: newVolume)
            
    }
    
    
    func actualVolume(for number: Double) -> Int {
        // Known points
        let isFirstHalf = (236...360).contains(number)
        let number1 =  isFirstHalf ? 236.0 : 0.0
        let value1 =  isFirstHalf ? 0.0 : 50.0
        let number2 = isFirstHalf ? 360.0 : 121.48747260922026
        let value2 = isFirstHalf ? 50.0 : 100.0
        
        // Calculate the slope (m)
        let slope = (value2 - value1) / (number2 - number1)
        
        // Calculate the value for the given number
        let result = slope * (number - number1) + value1
        
        return Int(result).clamped(to: 0...100)
    }
}


extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}


#Preview {
    VolumeBoostView(actualVolume: .constant(20), volumeBoost:  .constant(90))
}

