import SwiftUI

struct VolumeControlView: View {
    @State private var volume: Double = 0
    
    let totalDots = 14
    let activeColor: Color = .green
    let inactiveColor: Color = .gray
    let warningColor: Color = .red
    let maxWarningIndex = 11 // This is the index where the color changes to red
    
    var body: some View {
        VStack {
            Text("Volume Boost")
                .font(.title)
                .foregroundColor(.white)
            
            Text("\(Int(volume))%")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            ZStack {
                // Draw the dial background
                Circle()
                    .fill(Color.black)
                    .frame(width: 200, height: 200)
                
                // Draw the volume levels
                ForEach(0..<totalDots) { index in
                    Circle()
                        .fill(index < Int(volume / 5) ? (index < maxWarningIndex ? activeColor : warningColor) : inactiveColor)
                        .frame(width: 15, height: 15)
                        .offset(y: -100)
                        .rotationEffect(.degrees(Double(index) * 270.0 / Double(totalDots - 1) - 134))
                }
                
                // Draw the pointer
                Rectangle()
                    .fill(activeColor)
                    .frame(width: 4, height: 100)
//                    .offset(y: 50)
                    .rotationEffect(.degrees(Double(volume) * 180.0 / 100.0 - 0.0))
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let radius = Double(100)
                        let angle = atan2(value.location.y - radius, value.location.x - radius)
                        let adjustedAngle = angle + .pi / 2
                        let fixedAngle = adjustedAngle < 0 ? adjustedAngle + 2 * .pi : adjustedAngle
                        let newVolume = min(max(fixedAngle / .pi * 50, 0), 100)
                        volume = newVolume
                    }
            )
            .padding(.bottom, 20)
            
            HStack {
                Button(action: {
                    volume = 0
                }) {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.green)
                        Text("Min")
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    volume = 100
                }) {
                    HStack {
                        Text("Max")
                            .foregroundColor(.red)
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 50)
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct VolumeControlView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeControlView()
    }
}
