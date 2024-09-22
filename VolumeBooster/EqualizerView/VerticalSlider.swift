import SwiftUI

struct VerticalSlider: View {
    @Binding var value: Float
    

    var range: ClosedRange<Double>
    var step: Double
    var onEditingChanged: (Bool) -> Void = { _ in }
    
    @State private var sliderHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = .zero
    @State private var initialDragOffset: CGFloat = .zero
    
    var sliderType:Int = 1
    private let mWidth:CGFloat = 13
    private let mRoundTrackSize:CGFloat = 25
    private let mHeight:CGFloat = 200
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Track
                VStack {
                    if sliderType==1{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex:"#3E9B2F"), lineWidth: 2)
                            .frame(width: mWidth, height: geometry.size.height)
                    }
                    else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex:"#A0A0A0"))
                            .frame(width: mWidth, height: geometry.size.height)
                    }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                
                // Progress Indicator
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#84DB77"), Color(hex: "#3A842E")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: mWidth-2, height: calculateProgressHeight(in: geometry.size.height))
                        .animation(.easeInOut(duration: 0.2), value: value)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                
                // Draggable Button
                Circle()
                    .fill(Color.white)
                    .frame(width: mRoundTrackSize, height: mRoundTrackSize)
                    .offset(y: dragOffset)
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { gesture in
                                onEditingChanged(true)
                                
                                // Invert the drag direction by multiplying by -1
                                let dragAmount = (gesture.translation.height - initialDragOffset) * -1
                                initialDragOffset = gesture.translation.height
                                
                                updateValue(from: dragAmount, in: geometry.size.height)
                            }
                            .onEnded { _ in
                                onEditingChanged(false)
                                initialDragOffset = .zero
                            }
                    ).overlay{
                        Circle()
                            .offset(y: dragOffset)
                            .stroke(Color(hex:"3E9B2F"), lineWidth: 2)
                    }
            }
            .onAppear {
                sliderHeight = geometry.size.height
                dragOffset = calculateOffset(for: Double(value), in: geometry.size.height)
               
            }
            .onChange(of: value) { newValue in
                print("ON CHANGE")
                dragOffset = calculateOffset(for: Double(newValue), in: geometry.size.height)
            }
        }
        .frame(height: mHeight) // Set the desired height for the slider
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in }
                .onEnded { _ in }
        )
    }
    
    private func updateValue(from dragAmount: CGFloat, in height: CGFloat) {
        let dragPercentage = dragAmount / height
        let valueRange = range.upperBound - range.lowerBound
        let stepValue = valueRange * Double(dragPercentage)
        let newValue = Double(value) + stepValue // Adding instead of subtracting
        let clampedValue = max(min(newValue, range.upperBound), range.lowerBound)
        
        // Snap to the closest step
        let steppedValue = round(clampedValue / step) * step
        value = Float(steppedValue)
        
//        dragOffset = calculateOffset(for: Double(value), in: height)
    }
    
    private func calculateOffset(for value: Double, in height: CGFloat) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        let valuePercentage = (value - range.lowerBound) / valueRange
        return height / 2 - CGFloat(valuePercentage) * height // Adjusting offset to align with the value change
    }
    
    private func calculateProgressHeight(in height: CGFloat) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        let valuePercentage = (Double(value) - range.lowerBound) / valueRange
        return CGFloat(valuePercentage) * height
    }
}
