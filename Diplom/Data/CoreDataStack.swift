//
//  Coredata.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation
import CoreData

class CoreDataStack {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TMDB")

        container.loadPersistentStores { storeDesription, error in
            guard let error = error as NSError? else { return }
            fatalError("Failed to load persistent stores: \(error)")
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true

        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("Failed to pin viewContext to the current generation:\(error)")
        }

        return container
    }()
}
