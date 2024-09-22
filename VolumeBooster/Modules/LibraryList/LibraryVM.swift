//
//  LibraryVM.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 15.07.2024.
//

import Foundation
import SwiftUI
import CoreData

final class LibraryVM: ObservableObject {
    
    @Published var items: [LibraryListItem] = []
    @Published var songName = ""
    
    static let shared = LibraryVM()
    
    // Private initializer to prevent the creation of multiple instances
    private init() {
        // Initialize your view model here
    }
    var itemToRename: LibraryListItem?
    var itemToPlay: LibraryListItem?
    
    private let coreDataService = CoreDataService()
    
    func didSelect(item: LibraryListItem) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i].isSelected = !items[i].isSelected
    }
    
    func addFile(name: String, data: Data?, context: NSManagedObjectContext) {
        withAnimation {
            coreDataService.addAudioFile(name: name, audioData: data, context: context)
            
            fetchAudioFiles(context: context)
        }
        
    }
    
    func delete(item: LibraryListItem, context: NSManagedObjectContext) {
        withAnimation {
            coreDataService.deleteAudioFile(id: item.id, context: context)
            
            fetchAudioFiles(context: context)
        }
        
    }
    
    func update(context: NSManagedObjectContext) {
        withAnimation {
            guard songName.isEmpty == false, let item = itemToRename else { return }
            
            coreDataService.updateAudioFile(id: item.id, name: songName, url: item.audioFileURL, context: context)
            fetchAudioFiles(context: context)
        }
    }
    
    func map(cdModel: AudioFileCD) -> LibraryListItem? {
        
        guard let data = cdModel.audioData else {
            return nil
        }
        var bookmarkDataIsStale = false
        guard let playNow = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &bookmarkDataIsStale) else {
            return nil
        }
        
        let model = LibraryListItem(
            title: cdModel.name ?? "",
            isSelected: false,
            audioFileURL: playNow.absoluteString,
            id: cdModel.identifier ?? ""
        )
        return model
    }
    
    func fetchAudioFiles(context: NSManagedObjectContext) {
        let request: NSFetchRequest<AudioFileCD> = AudioFileCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AudioFileCD.createdAt, ascending: true)]
        do {
            let elems = try context.fetch(request)
            self.items = map(cdModels: elems)
        } catch {
            print("Error fetching audio files: \(error)")
        }
    }
    
    func map(cdModels: [AudioFileCD]) -> [LibraryListItem] {
        let elems = cdModels.compactMap { map(cdModel: $0) }
        return elems
    }
}

struct LibraryListItem: Identifiable, Hashable {
    let title: String
    var isSelected: Bool
    let audioFileURL: String
    var id: String
    
    static let stub = LibraryListItem(title: "Test item", isSelected: false, audioFileURL: "", id: "1")
}
