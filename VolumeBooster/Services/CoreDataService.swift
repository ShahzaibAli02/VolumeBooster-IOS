//
//  CoreDataService.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import Foundation
import CoreData

struct CoreDataService {
    
    private let persistance = PersistenceController.shared
    
    // MARK: - Audio file
    
    func addAudioFile(name: String, audioData: Data?, context: NSManagedObjectContext) {
        let newAudioFile = AudioFileCD(context: context)
        newAudioFile.identifier = UUID().uuidString
        newAudioFile.name = name
        newAudioFile.audioData = audioData
        newAudioFile.createdAt = Date()
        context.save(with: .addSong)
    }
    
    func fetchAudioFile(id: String, context: NSManagedObjectContext) -> AudioFileCD? {
        let predicate = NSPredicate(format: "identifier == %@", id)
        let result = context.fetchObject(object: AudioFileCD.self, descriptors: [], predicate: predicate, limit: 1)
        switch result {
        case .success(let success):
            return success.first(where: { $0.identifier == id })
        case .failure:
            return nil
        }
    }
    
    func deleteAudioFile(id: String, context: NSManagedObjectContext) {
        guard let item = fetchAudioFile(id: id, context: context) else {
            return
        }
        
        context.delete(item)
        context.save(with: .removeSong)
    }
    
    func updateAudioFile(id: String, name: String, url: String, context: NSManagedObjectContext) {
        guard let item = fetchAudioFile(id: id, context: context) else {
            return
        }
        item.name = name
        item.fileURL = url
        item.createdAt = Date()
        context.save(with: .updateSong)
    }
}

extension NSManagedObjectContext {
    
    func fetchObject<T: NSManagedObject>(object: T.Type,
                                         descriptors: [NSSortDescriptor],
                                         predicate: NSPredicate?,
                                         resultType: NSFetchRequestResultType = .managedObjectResultType,
                                         returnsObjectsAsFaults: Bool = true,
                                         limit: Int? = nil) -> Result<[T], AppError> {
        guard let entityName = object.entity().name else {
            return .failure(.logic("Don't have entity name"))
        }
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = descriptors
        request.predicate = predicate
        request.resultType = resultType
        request.returnsObjectsAsFaults = returnsObjectsAsFaults
        limit.flatMap { request.fetchLimit = $0 }
        
        do {
            let values = try self.fetch(request)
            return .success(values)
        } catch {
            return .failure(.error(error))
        }
    }
}

/**
 Contextual information for handling Core Data context save errors.
 */
enum ContextSaveContextualInfo: String {
    case addSong
    case removeSong
    case updateSong
}

extension NSManagedObjectContext {
   
    /**
     Save a context, or handle the save error (for example, when there data inconsistency or low memory).
     */
    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }
        do {
            mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            try setQueryGenerationFrom(.current)
            try save()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

/*
 @FetchRequest(
     entity: NoteItemCD.entity(),
     sortDescriptors: [NSSortDescriptor(keyPath: \NoteItemCD.createdAt, ascending: true)]
 ) private var results: FetchedResults<NoteItemCD>
 @Environment(\.managedObjectContext) var context
 @EnvironmentObject var appManager: AppManager
 @StateObject private var viewModel = NoteViewModel()
 */
