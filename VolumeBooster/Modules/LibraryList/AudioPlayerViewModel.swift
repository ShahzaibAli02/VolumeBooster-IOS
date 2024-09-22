import SwiftUI
import AVFoundation

class AudioPlayerViewModel: NSObject, ObservableObject ,UIDocumentPickerDelegate{
    
    //    private var player: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    public var equalizerAudio: AVAudioUnitEQ?
    private var isInitialized : Bool = false
    private var seekOffset : Double = 0.0
    //    private var viewModel : LibraryVM
    
    
    //NEW
    @Published var eqBands: [Float] = Array(repeating: 0.0, count: 8)
    
    
    @Published var currentIndex = 0
    
    @Published var showingShareAlert = false
    
    @Published var hasNext: Bool = true
    @Published var hasPrev: Bool = true
    
    @Published var isPlaying = false
    var isCompleted = false
    @Published var songName = ""
    var url : URL?
    @Published var canHidePlayer = true
    @Published var progress: Double = 0.0 {
        didSet{
            print("PROGRESS =>")
        }
    }
    @Published var currentTime: Double = 0.0 {
        didSet{
            print("currentTime =>")
        }
    }
    @Published var duration: Double = 0.0
    @Published var boostLevel: Float = 0.0 {
        didSet {
            updateBoost()
        }
    }
    private var progressTimer: Timer?
    private var isSeeking : Bool = false
    private let TAG = "AudioPlayerViewModel"
    
    private var coreDataService = CoreDataService()
    
    func nextAudio(){
        if hasNextAudio() {
            loadAudio(index:currentIndex+1)
            return
        }
        print("NO NEXT SONG TO PLAY")
    }
    private func loadAudio(index:Int) {
        
        
        let item = LibraryVM.shared.items[index]
        LibraryVM.shared.itemToPlay = item
        loadAudio(index:index,item: item)
        playPauseAudio()
        LibraryVM.shared.didSelect(item: item)
        
    }
    func getSongNameWithOutExtension() -> String {
        // Remove the file extension from the song name
        return (songName as NSString).deletingPathExtension
    }
    
    func previousAudio(){
        if hasPrevAudio() {
            loadAudio(index:currentIndex-1)
            return
        }
        print("NO PREV SONG TO PLAY")
    }
    func seek(to time: Double) {
        stopProgressTimer()
        isSeeking = true
        print("SEEK TO \(time)")
        currentTime = time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [self] in
            
            if currentTime != time {
                return
            }
            
            guard let playerNode = self.playerNode else {
                print("Player node or audio engine not initialized")
                return
            }
            
            // Stop the player node
            playerNode.stop()
            
            // Calculate the frame position
            guard let audioFile = try? AVAudioFile(forReading: url!) else {
                print("Failed to create AVAudioFile")
                return
            }
            let sampleRate = audioFile.processingFormat.sampleRate
            let framePosition = AVAudioFramePosition(time * sampleRate)
            
            // Schedule playing from the new position
            playerNode.scheduleSegment(audioFile, startingFrame: framePosition, frameCount: AVAudioFrameCount(audioFile.length - framePosition), at: nil)
            
            // Start playing if it was playing before
            if isPlaying {
                playerNode.play()
            }
            
            // Update the current time and progress
            
            if duration > 0 {
                progress = time / duration
            }
            
            
            isSeeking = false
            currentTime = time
            seekOffset = time
            startProgressTimer()
            print("CURREN TIME 1  \(currentTime)")
            print("Seeked to: \(time) seconds CURRENT TIME \(currentTime)")
        }
        
    }
    
    var isShare : Bool = false
    func shareAudio() {
        isShare = true
        showShareAlert()
       }

       private func showShareAlert() {
           showingShareAlert = true
       }

       func confirmShare() {
           showingShareAlert = false
           shareEqualizedAudio(toShare: isShare)
       }
    
//    func shareAudio(){
//        //add check to avoid out of index exception
//        
//        shareEqualizedAudio(toShare: true)
////        shareAudio(item: LibraryVM.shared.items[currentIndex])
//    }
    

    
    func downloadAudio() {
        
        isShare = false
        showShareAlert()

    }
    

    
    func hasNextAudio() -> Bool {
        return  currentIndex+1 > -1 && currentIndex+1 < LibraryVM.shared.items.count
    }
    
    func hasPrevAudio() -> Bool {
        return  currentIndex-1 > -1 && currentIndex-1 < LibraryVM.shared.items.count
    }



   
    @Published var sharingProgress: Double = 0.0
    @Published var isSharing: Bool = false

    @Published var processedAudioURL: URL?
    func shareEqualizedAudio(toShare:Bool) {
        if isSharing{
            return
        }
          guard let audioEngine = audioEngine,
                let playerNode = playerNode,
                let equalizerAudio = equalizerAudio,
                let url = url else {
              print("Audio engine or components not initialized")
              return
          }

          isSharing = true
          sharingProgress = 0.0

//          let wasPlaying = isPlaying
//          if wasPlaying {
//              playerNode.pause()
//          }
       

      
          do {
              let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
              let outputURL = documentsPath.appendingPathComponent(getSongNameWithOutExtension()+"-volume_booster.m4a")

              // Configure audio format with compression
              var outputSettings: [String: Any] = [
                  AVFormatIDKey: kAudioFormatMPEG4AAC,
                  AVSampleRateKey: audioEngine.mainMixerNode.outputFormat(forBus: 0).sampleRate,
                  AVNumberOfChannelsKey: 2,
                  AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                  AVEncoderBitRateKey: 128000 // 128 kbps, adjust as needed
              ]

              let audioFile = try AVAudioFile(forWriting: outputURL, settings: outputSettings)

              let mainMixer = audioEngine.mainMixerNode
              let bufferSize: AVAudioFrameCount = 8192
              var totalFrames: AVAudioFrameCount = 0

              let channelCount = 2
              let pcmBuffer = AVAudioPCMBuffer(pcmFormat: mainMixer.outputFormat(forBus: 0),
                                               frameCapacity: bufferSize)!

              mainMixer.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) in
                  guard let self = self else { return }
                  do {
                      pcmBuffer.frameLength = buffer.frameLength
                      let audioBuffer = pcmBuffer.audioBufferList.pointee.mBuffers
                      
                      for channel in 0..<channelCount {
                          memcpy(audioBuffer.mData! + channel * Int(bufferSize) * MemoryLayout<Float>.size,
                                 buffer.floatChannelData![channel],
                                 Int(buffer.frameLength) * MemoryLayout<Float>.size)
                      }
                      
                      try audioFile.write(from: pcmBuffer)
                      totalFrames += buffer.frameLength
                      let progress = Double(totalFrames) / Double(self.duration * (self.audioEngine?.mainMixerNode.outputFormat(forBus: 0).sampleRate ?? 0))
                      DispatchQueue.main.async {
                          self.sharingProgress = progress
                      }
                  } catch {
                      print("Error writing buffer to file: \(error.localizedDescription)")
                  }
              }
//              stopAudio()
              isPlaying = false
              stopProgressTimer()
              playerNode.stop()
              if let audioFile = try? AVAudioFile(forReading: url) {
                  playerNode.scheduleFile(audioFile, at: nil, completionHandler: { [weak self] in
                      guard let self = self else { return }
                      DispatchQueue.main.async {
                        
                      
                          print("AUDIO ENGINE ",  self.audioEngine == nil)
                          mainMixer.removeTap(onBus: 0)
                          self.audioEngine?.stop()
                          
                          self.processedAudioURL = outputURL
                        
                          if toShare {
                              self.shareProcessedAudio(url: outputURL)
                          }else{
                              self.saveProcessedAudio()
                          }
//                          self.showingSaveDialog = true
//
//                          if wasPlaying {
//                              self.playPauseAudio()
//                          }
                          self.stopAudio()
                          self.isSharing = false
                      }
                  })
              }

              try audioEngine.start()
              playerNode.play()
              isPlaying = true
              startProgressTimer()
//              playPauseAudio()

          } catch {
              print("Error sharing equalized audio: \(error.localizedDescription)")
              isSharing = false
          }
      }
    func saveProcessedAudio() {
           guard let sourceURL = processedAudioURL else {
               print("No processed audio available")
               return
           }

           // Create a temporary directory to store the file
           let temporaryDirectoryURL = FileManager.default.temporaryDirectory
           let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(getSongNameWithOutExtension()+"-volume_booster.m4a")

           do {
               // If a file already exists at the temporary location, remove it
               if FileManager.default.fileExists(atPath: temporaryFileURL.path) {
                   try FileManager.default.removeItem(at: temporaryFileURL)
               }

               // Copy the processed audio to the temporary location
               try FileManager.default.copyItem(at: sourceURL, to: temporaryFileURL)

               // Create a document picker to allow the user to choose where to save the file
               let documentPicker = UIDocumentPickerViewController(forExporting: [sourceURL], asCopy: true)
               documentPicker.delegate = self
               documentPicker.shouldShowFileExtensions = true

               // Present the document picker
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController {
                   rootViewController.present(documentPicker, animated: true, completion: nil)
               }
           } catch {
               print("Error preparing file for saving: \(error.localizedDescription)")
           }
       }

       // UIDocumentPickerDelegate method
       func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           guard let selectedURL = urls.first else {
               print("No destination URL selected")
               return
           }

           print("File saved successfully to: \(selectedURL.path)")
           // You can add any additional logic here, such as updating UI or model
       }

    private func shareProcessedAudio(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.keyWindow {
            window.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        sharingProgress = 0.0 // Reset progress
    }
    func loadAudio(index: Int,item: LibraryListItem) {
        print("\(TAG) => loadAudio()")
        
        
        currentIndex = index
        
        hasNext = hasNextAudio()
        hasPrev = hasPrevAudio()
        
        stopAudio()
        guard let model = coreDataService.fetchAudioFile(id: item.id, context: PersistenceController.shared.container.viewContext),
              let data = model.audioData else {
            print("Audio file not found")
            return
        }
        
        var bookmarkDataIsStale = false
        let playNow = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &bookmarkDataIsStale)
        
        guard let url = playNow else {
            print("Audio file not found url")
            return
        }
        
        songName = item.title
        setupAudioEngine(with: url)
        isCompleted = false
    }
    
    func startProgressTimer() {
        // Invalidate any existing timer before starting a new one
        progressTimer?.invalidate()
        
        // Create and start a new timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
        
            
            DispatchQueue.main.async {
                guard let player = self.playerNode, let lastRenderTime = player.lastRenderTime else {
                    return
                }
                
                
                // Obtain player time
                guard let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
                    return
                }
                
                
        
                
                // Calculate the current time`
                let nonActualcurrentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
                self.currentTime = nonActualcurrentTime + self.seekOffset
             
                // Update progress and handle end of playback
                self.getDuration { duration in
                
                    DispatchQueue.main.async {
                        if let duration = duration {
                            self.progress =  self.currentTime / duration
                            self.duration = duration
                            
                    
                            if self.currentTime >= duration {
                                self.stopAudio()
                            }
                        }
                    }
                  
                }
                
            }
   
          
        }
    }
    
    
    // Method to stop the timer
    func stopProgressTimer() {
        // Invalidate the timer
        progressTimer?.invalidate()
        progressTimer = nil
    }
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }
    
    var file:AVAudioFile? = nil
    private func setupAudioEngine(with url: URL) {
        print("URL \(url)")
        self.url = url
        let lastBoostLevel = boostLevel
        configureAudioSession()
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        equalizerAudio = AVAudioUnitEQ(numberOfBands: 7)
        
        guard let audioEngine = audioEngine,
              let playerNode = playerNode,
              let boostUnit = equalizerAudio else { return }
        
        
        do{
            file = try AVAudioFile(forReading: url)
        }
        catch{}
        
        configureEQBands()
        boostLevel = lastBoostLevel
//        updateBoost()
        audioEngine.attach(playerNode)
        audioEngine.attach(boostUnit)
        
        
        
        //        let format = getCommonFormat(input: input, output: output)
        audioEngine.connect(playerNode, to: boostUnit, format: file!.processingFormat)
        audioEngine.connect(boostUnit, to: audioEngine.mainMixerNode, format: file!.processingFormat)
        
        
        
        
        do {
            
            playerNode.scheduleFile(file!, at: nil)
            try audioEngine.start()
            isInitialized = true

            print("Audio engine started successfully")
            startProgressTimer()
        } catch {
            isInitialized = false
            print("Error setting up audio engine: \(error.localizedDescription)")
        }
    }
    private func configureEQBands() {
        
        
        guard let equalizerAudio = equalizerAudio else { return }
        
        let frequencies: [Float] = [32, 64, 200, 500, 1000, 4000, 16000]
        for (index, frequency) in frequencies.enumerated() {
            let band = equalizerAudio.bands[index]
            band.filterType = .parametric
            band.frequency = frequency
            band.gain = eqBands[index+1]
            band.bandwidth = 1.0
            band.bypass = false
        }
        
        setPreampGain(eqBands[0])
        
    }
    func setEQBandGain(index: Int, gain: Float) {
        DispatchQueue.main.async {
            guard let equalizerAudio = self.equalizerAudio, index < equalizerAudio.bands.count else { return }
            equalizerAudio.bands[index].gain = gain
            self.eqBands[index + 1] = gain // +1 because index 0 is preamp
        }
     
    }
    func setPreampGain(_ gain: Float) {
        boostLevel = gain
        eqBands[0] = gain
    }
    
    func playPauseAudio() {
        print("\(TAG) => playPauseAudio()")
        print("\(TAG) => isCOMPLETED ()",isCompleted)
        guard let playerNode = playerNode, let audioEngine = audioEngine else { return }
        
        if isCompleted {
            loadAudio(index: currentIndex)
            return
        }
        if isPlaying {
            playerNode.pause()
            isPlaying = false
            stopProgressTimer()
        } else {
            if !audioEngine.isRunning {
                do {
                    try audioEngine.start()
                    
                } catch {
                    print("Failed to start audio engine: \(error.localizedDescription)")
                    return
                }
            }
            startProgressTimer()
            playerNode.play()
            isPlaying = true
            canHidePlayer = false
        }
        print("isPlaying: \(isPlaying)")
    }
    
    func stopAudio() {
        print("\(TAG) => stopAudio()")
        playerNode?.stop()
        isPlaying = false
        isCompleted = true
        progress = 0.0
        canHidePlayer = true
        seekOffset = 0.0
        currentTime = 0.0
        
        stopProgressTimer()
    }
    
    func boostVolume(value: Float) {
        print("\(TAG) => boostVolume(value: \(value))")
        boostLevel = value
    }
    
    //    private func updateBoost() {
    //        let boost = (boostLevel / 100.0) * 2 // Max boost of 24dB
    //        audioEngine?.mainMixerNode.outputVolume = 1+boost
    //    }
    
    private func updateBoost() {
        DispatchQueue.main.async {
            self.audioEngine?.mainMixerNode.outputVolume = pow(10, self.boostLevel / 20) // Convert dB to linear gain
        }
       
    }
    
    
    func bassBoost(value: Float) {
        guard value >= 1 && value <= 100 else {
            print("Bass boost value should be between 1 and 100")
            return
        }
        
        // Convert the 1-100 range to a more suitable range for EQ adjustment (e.g., 0-12 dB)
        let maxBoost: Float = 12.0
        let boostGain = (value / 100.0) * maxBoost
        
        guard let equalizerAudio = equalizerAudio else { return }
        
        for (index, band) in equalizerAudio.bands.enumerated() {
            if band.frequency <= 250 {  // Boost frequencies up to 250 Hz
                let scaleFactor = 1 - (band.frequency / 250)  // Apply more boost to lower frequencies
                setEQBandGain(index: index, gain: boostGain * scaleFactor)
            }
        }
        
        print("Bass boost applied: up to \(boostGain) dB for frequencies <= 250 Hz")
    }
    
    func setGain(forBand band: Int, gain: Float) {
        guard let boostUnit = equalizerAudio else { return }
        guard band < boostUnit.bands.count else { return }
        boostUnit.bands[band].gain = gain
    }
    
    private func getDuration(completion: @escaping (Double?) -> Void) {
        let asset = AVAsset(url: url!)
        if #available(iOS 16.0, *){
            Task {
                let duration = try await asset.load(.duration)
                completion(Double(CMTimeGetSeconds(duration)))
            }
        }
        else{
            let duration = asset.duration
            completion(Double(CMTimeGetSeconds(duration)))
        }
        
        //        return Double(CMTimeGetSeconds(duration))
        
    }
}

extension AudioPlayerViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        progress = 0.0
        canHidePlayer = true
    }
}
