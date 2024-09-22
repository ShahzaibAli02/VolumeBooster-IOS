//
//  DetailsSongView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 15.07.2024.
//

import SwiftUI

struct DetailsSongView: View {
    
    
    @State private var isPlaying: Bool = false
    
    //    @State private var progress: Double = 0
    
    @ObservedObject  var playerViewModel :AudioPlayerViewModel
    
    @State private var isCollapsedVolumeBooster = false
    @State private var isCollapsedBassBooster = true
    @State private var isCollapsedInfo = true
    
    @State private var progressValue = 0
    
    
    @State private var volumeBoostValue = 0
    @State private var volumeBassValue = 0
    
    @State private var volumeBoostDegreeValue:Double = 65
    @State private var bassBoostDegreeValue:Double = 65
    
    
    
    let item: LibraryListItem
    init( playerViewModel: AudioPlayerViewModel, isCollapsedVolumeBooster: Bool = false, isCollapsedBassBooster: Bool = true, isCollapsedInfo: Bool = true,
          progressValue: Int = 0, volumeBoostValue: Int = 0,
          volumeBassValue: Int = 0,
          item: LibraryListItem) {
        
        self.playerViewModel = playerViewModel
        self.isCollapsedVolumeBooster = isCollapsedVolumeBooster
        self.isCollapsedBassBooster = isCollapsedBassBooster
        self.isCollapsedInfo = isCollapsedInfo
        self.progressValue = progressValue
        self.volumeBoostValue = volumeBoostValue
        self.volumeBassValue = volumeBassValue
        self.item = item
        //        self.progress = playerViewModel.progress
    }
    
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                makeBgView()
                ScrollView {
                    VStack {
                        
                        Spacer()
                        
                        PlayerSongInfoView(
                            isCollapsed: isCollapsedInfo,
                            songName: playerViewModel.songName
                        )
                        
                        
                        if !isCollapsedVolumeBooster {
                            VolumeBoostView(actualVolume: $volumeBoostValue, volumeBoost: $volumeBoostDegreeValue)
                        }
                        
                        if !isCollapsedBassBooster {
                            BassBoostView(actualVolume: $volumeBassValue, volumeBoost: $bassBoostDegreeValue)
                        }
                        if(!isCollapsedInfo)
                        {
                            EqualizerView(viewModel: playerViewModel)
                            
                        }
                        
                        PlayerSetupView(model: .init(hasPremium: true)) { item in
                            isCollapsedBassBooster = true
                            isCollapsedVolumeBooster = true
                            isCollapsedInfo = true
                            switch item {
                            case .volumeBoost:
                                isCollapsedVolumeBooster = false
                            case .bass:
                                isCollapsedBassBooster = false
                            case .equilaizer:
                                isCollapsedInfo = false
                            }
                        }
                        
                        PlayerSongProgressView(progressValue: $playerViewModel.currentTime, duration: playerViewModel.duration, onSeek: { newValue in
                            
                            playerViewModel.seek(to: newValue)
                        })
                        PlayerControlView(isPlaying:$playerViewModel.isPlaying,hasNext: $playerViewModel.hasNext,hasPrev: $playerViewModel.hasPrev ) { item in
                            
                            if item == PlayerControlType.play ||  item == PlayerControlType.pause {
                                playerViewModel.playPauseAudio()
                                return
                            }
                            if item == PlayerControlType.skipRight {
                                playerViewModel.nextAudio()
                                return
                            }
                            
                            if item == PlayerControlType.skipLeft {
                                playerViewModel.previousAudio()
                                return
                            }
                            
                        }
                        
                    }
                    .frame(minHeight: proxy.size.height)
                }
                
            }
        }
        .alert((playerViewModel.isShare ? "Share" : "Download")+" Audio", isPresented: $playerViewModel.showingShareAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                playerViewModel.confirmShare()
            }
        } message: {
            Text("Are you sure you want to \(playerViewModel.isShare ? "Share" : "Download") this audio? It will play audio and can take some time")
        }
        .sharingProgressOverlay(isSharing: $playerViewModel.isSharing, progress: $playerViewModel.sharingProgress)
        .onChange(of: volumeBoostValue) { newValue in
            
            playerViewModel.boostVolume(value: Float(newValue))
            print("Volume Boost Value Changed to \(newValue)")
        }
        .onChange(of: volumeBassValue) { newValue in
            
            playerViewModel.bassBoost(value: Float(newValue))
            print("Bass Changed Changed to \(newValue)")
            
        }
        
        .animation(.easeInOut, value: isCollapsedInfo)
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack{
                    Button(action: {
                        playerViewModel.shareAudio()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        playerViewModel.downloadAudio()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.white)
                    }
                    
                }
                
            }
        }
    }
    
    private func makeBgView() -> some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.29, green: 0.81, blue: 0.2).opacity(0.36), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.08, green: 0.21, blue: 0.06).opacity(0.36), location: 0.79),
                    Gradient.Stop(color: Color(red: 0.08, green: 0.21, blue: 0.06).opacity(0), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.07),
                endPoint: UnitPoint(x: 0.5, y: 0.59)
            )
            .ignoresSafeArea()
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct DetailsSongView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsSongView(playerViewModel: AudioPlayerViewModel(), item: .init(title: "Test", isSelected: true, audioFileURL: "", id: "1"))
    }
}
//#Preview {
//
//    DetailsSongView(volumeBoostValueBinding:$volumeBoostValue, item: .init(title: "Test", isSelected: true, audioFileURL: "", id: "1"))
//}
