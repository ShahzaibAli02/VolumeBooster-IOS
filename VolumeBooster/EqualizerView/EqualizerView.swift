import SwiftUI


struct EqualizerView: View {
    @ObservedObject var viewModel: AudioPlayerViewModel
    
    let bands = ["PR", "32", "64", "200", "500", "1k", "4k", "16k"]
    let presets = ["Custom", "Rock", "Jazz", "Reggae", "Rap", "R&B", "Dance", "Electronic", "Acoustic", "Classical"]
    
    @State private var selectedPreset: String = "Custom"
    
    var body: some View {
        VStack {
            HStack {
                Button("Reset") {
                    resetEqualizer()
                }
                Spacer()
                Button("Save") {
                    // Save logic here
                }
                .foregroundColor(.green)
            }
            
            Menu {
                ForEach(presets, id: \.self) { preset in
                    Button(preset) {
                        selectedPreset = preset
                        applyPreset(preset)
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text(selectedPreset)
                        .foregroundColor(.green)
                        .underline()
                    
                    VStack{
                        Image(systemName: "chevron.up").foregroundColor(.white)
                        Image(systemName: "chevron.down").foregroundColor(.white)
                    }
                }
            }
            
            HStack(alignment: .top, spacing: 10) {
                ForEach(0..<bands.count, id: \.self) { index in
                    EqualizerSlider(label: bands[index], value: $viewModel.eqBands[index]) { editing in
                        if !editing {
                            if index == 0 {
                                viewModel.setPreampGain(viewModel.eqBands[index])
                            } else {
                                viewModel.setEQBandGain(index: index - 1, gain: viewModel.eqBands[index])
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black)
    }
    
    private func resetEqualizer() {
        for i in 0..<viewModel.eqBands.count {
            viewModel.eqBands[i] = 0.0
        }
        viewModel.setPreampGain(0.0)
        for i in 0..<7 {
            viewModel.setEQBandGain(index: i, gain: 0.0)
        }
    }
    private func applyPreset(_ preset: String) {
        // Reset the equalizer to default values before applying a new preset
        resetEqualizer()
        
        // Define values for each preset
        let presetValues: [String: [Float]] = [
            "Rock": [2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -2.0],  // Rock usually boosts lower mids and bass
            "Jazz": [0.0, -0.5, -1.0, 0.0, 0.5, 1.0, 1.5, 1.0],   // Jazz might have a more balanced or slightly boosted high end
            "Reggae": [1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -1.5, -2.0], // Reggae typically emphasizes bass and lower mids
            "Rap": [2.0, 2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0],     // Rap often boosts the bass and midrange
            "R&B": [1.0, 1.0, 0.5, 0.0, -0.5, -0.5, 0.0, 0.0],     // R&B usually has a smooth bass and midrange boost
            "Dance": [2.0, 2.5, 2.0, 1.5, 1.0, 0.5, -0.5, -1.0],   // Dance music often has a pronounced bass and midrange
            "Electronic": [1.5, 1.5, 1.0, 0.5, -0.5, -1.0, -1.5, -2.0], // Electronic music usually has a deep bass and sometimes a cut in mids
            "Acoustic": [0.5, 0.0, -0.5, -1.0, -1.5, -1.5, -1.0, -0.5], // Acoustic often cuts lower mids and boosts highs slightly
            "Classical": [0.0, -0.5, -1.0, -1.5, -1.0, -0.5, 0.0, 0.5] // Classical might have a slightly scooped midrange and boosted highs
        ]
        
        if let values = presetValues[preset] {
            for (index, value) in values.enumerated() {
                if index == 0 {
                    viewModel.setPreampGain(value)
                } else {
                    viewModel.setEQBandGain(index: index - 1, gain: value)
                }
            }
        }
    }


}

//struct ContentView: View {
//    @StateObject private var viewModel = AudioPlayerViewModel()
//
//    var body: some View {
//        EqualizerView(viewModel: viewModel)
//    }
//}

//#Preview {
//    ContentView()
//}
