//
//  LibraryListView.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct LibraryListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = LibraryVM.shared
    @StateObject private var playerViewModel = AudioPlayerViewModel()
    @State private var path = NavigationPath()
    @State private var isDocumentPickerPresented = false
    @State private var showingAlert = false

    
    var body: some View {
        NavigationStack(path: $path) {
            makeBody()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("Library")
                                .font(.title)
                                .foregroundStyle(.white)
                            Spacer()
                            
                            Button(action: {
                                path.append(ScreenNavigationType.settings)
                            }) {
                                Image(.gearImg)
                                    .foregroundStyle(.white)
                                    .font(.largeTitle)
                            }
                        }
                        
                    }
                }
                .navigationDestination(for: ScreenNavigationType.self, destination: { screen in
                    switch screen {
                    case .detailList(let item):
                        DetailsSongView(playerViewModel:playerViewModel , item: item)
                        
                    case .settings:
                        SettingsView()
                          
                    }
                })
                .background(Color.black)
                .fileImporter(
                    isPresented: $isDocumentPickerPresented,
                    allowedContentTypes: [UTType.audio],
                    allowsMultipleSelection: false
                ) { result in
                    handleFileImport(result: result)
                }
                .animation(.easeInOut, value: playerViewModel.isPlaying)
                .animation(.easeInOut, value: playerViewModel.canHidePlayer)
                .task {
                    Task { @MainActor in
                        viewModel.fetchAudioFiles(context: viewContext)
                    }
                }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let elems = try result.get()
            guard let selectedFileURL = elems.first else { return }
            
            let startAccess = selectedFileURL.startAccessingSecurityScopedResource()
            defer {
                // Must stop accessing once stop using
                if startAccess {
                    selectedFileURL.stopAccessingSecurityScopedResource()
                }
            }
            
            let bookmarkData = try? selectedFileURL.bookmarkData()
            
            let fileName = selectedFileURL.lastPathComponent
            viewModel.addFile(name: fileName, data: bookmarkData, context: viewContext)
        } catch {
            print("Error importing file: \(error)")
        }
    }
    
    private func makeBody() -> some View {
        ZStack {
            
            if viewModel.items.isEmpty {
                Text("No items added yet")
                    .font(.title)
                    .foregroundStyle(.white)
            } else {
                VStack{
//                    VStack {
//                            Text("Equalizer")
//                                .font(.headline)
//                            
//                        ForEach(0..<getRange(), id: \.self) { index in
//                                VStack(alignment: .leading) {
//                                    Text("Band \(index + 1)")
//                                    Slider(
//                                        value: Binding(
//                                            get: {
//                                                getEqRangeBand(index: index)
//                                            },
//                                            set: { newValue in
//                                                playerViewModel.setEQBandGain(index: index, gain: newValue)
//                                            }
//                                        ),
//                                        in: -24...24,
//                                        step: 0.1
//                                    )
//                                    .padding()
//                                }
//                            }
//                        }
//                        .padding()
                    
            
                    makeList()
                }
          
            }
            VStack {
                
    
                               
                Spacer()
              
                               
                HStack {
                    Spacer()
                    makeAddButton()
                }
                .padding()
                .padding(.horizontal)
            }
            .opacity(playerViewModel.canHidePlayer ? 1 : 0)
            
            VStack {
                Spacer()
                if let item = viewModel.itemToPlay {
                    playerView(item: item)
                }
            }
        } .sharingProgressOverlay(isSharing: $playerViewModel.isSharing, progress: $playerViewModel.sharingProgress)
    }
    
    private func getEqRangeBand(index:Int) -> Float {
        return playerViewModel.equalizerAudio?.bands[index].gain ?? 0.0
    }
    private func getRange() -> Int {
       return  playerViewModel.equalizerAudio?.bands.count ?? 0
    }
    private func makeList() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    LibraryListItemView(item: item) {
                        if item.isSelected {
                            path.append(ScreenNavigationType.detailList(item))
                        } else {
                            viewModel.itemToPlay = item
                            playerViewModel.loadAudio(index:index,item: item)
                            // playerViewModel.boostVolume(value: 100)
                            playerViewModel.playPauseAudio()
                            
                            viewModel.didSelect(item: item)
                        }
                    } onTapMore: { style in
                        playerViewModel.stopAudio()
                        viewModel.itemToPlay = nil
                        switch style {
    
                        case .rename:
                            showingAlert = true
                            viewModel.itemToRename = item
                        case .delete:
                            viewModel.delete(item: item, context: viewContext)
                        }
                    }
                    .frame(height: 40)
                }
            }
            .padding(.horizontal, 16)
        }
        .alert("Enter a new song name", isPresented: $showingAlert) {
            TextField("Enter your name", text: $viewModel.songName)
            Button("OK", action: submit)
            Button(role: .cancel) {
                showingAlert = false
            } label: {
                Text("Cancel")
            }

        } message: {
            Text("")
        }
    }
    
    private func submit() {
        showingAlert = false
        viewModel.update(context: viewContext)
    }
    
    private func makeAddButton() -> some View {
        Button(action: {
            isDocumentPickerPresented = true
        }, label: {
            Image(.plusImg)
        })
    }
    
    private func playerView(item: LibraryListItem) -> some View {
        SmallPlayerView(
            progress: playerViewModel.progress,
            item: item,
            isPlaying: playerViewModel.isPlaying
        ) {
                playerViewModel.playPauseAudio()
            } onTapClose: {
                viewModel.didSelect(item: item)
                playerViewModel.stopAudio()
                viewModel.itemToPlay = nil
            } onTapPlayer: {
                path.append(ScreenNavigationType.detailList(item))
            }
    }
}

#Preview {
    LibraryListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

enum ScreenNavigationType: Identifiable, Hashable {
    case detailList(LibraryListItem)
    case settings
    
    var id: String {
        switch self {
        case .detailList(let libraryListItem):
            return libraryListItem.id
        case .settings:
            return "settings"
        }
        
    }
}
