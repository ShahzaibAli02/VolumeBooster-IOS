//
//  BassView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 11.07.2024.
//


import SwiftUI

struct BassBoostView: View {
  
    @Binding var actualVolume: Int
    @Binding var volumeBoost: Double
    
    private let INNER_CIRCLE_WIDTH = 220.0
    private let INNER_CIRCLE_HEIGHT = 220.0
    
    private let OUTER_PROGRESS_CIRCLE_HEIGHT = 300.0
    private let OUTER_PROGRESS_CIRCLE_WIDTH = 300.0
    
    var body: some View {
        ZStack {
            backgroundColor
            VStack(spacing: 20) {
                titleView
                percentageView
                circularSlider
              
                minMaxLabels
            }
        }
    }
    
    private var backgroundColor: some View {
        Color.clear.edgesIgnoringSafeArea(.all)
    }
    
    private var titleView: some View {
        Text("Bass Boost")
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
                .frame(width: INNER_CIRCLE_WIDTH, height: INNER_CIRCLE_HEIGHT)
            
            
            HalfCircularProgressBar(progress: Double(actualVolume), color: .blue)
                .frame(width: OUTER_PROGRESS_CIRCLE_WIDTH, height: OUTER_PROGRESS_CIRCLE_HEIGHT)
                    
            sliderKnob
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged(handleDrag)
        )
    }
    
    

    
    private var sliderKnob: some View {

        Rectangle()
            .fill(Color.green)
            .frame(width: 8, height: 20)
            .offset(y: -90)
            .rotationEffect(.degrees(volumeBoost / 100 * 360))
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

#Preview {
    BassBoostView(actualVolume: .constant(2),volumeBoost : .constant(65.0))
}
