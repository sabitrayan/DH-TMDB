//
//  FavoritesProvider.swift
//  Diplom
//
//  Created by ryan on 09.11.2021.
//

import CoreData

class FavoritesProvider {

    private(set) var persistentContainer: NSPersistentContainer


    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    lazy var fetchedResultsController: NSFetchedResultsController<Favorite> = {
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        controller.delegate = fetchedResultsControllerDelegate

        do {
            try controller.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }

        return controller
    }()

    // MARK: - Initialization

    init(
        with persistentContainer: NSPersistentContainer,
        fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    ) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    // MARK: - Operations

    func add(_ movieId: String, in context: NSManagedObjectContext) {
        print("Favoriting: \(movieId)")

        context.performAndWait {
            let favorite = Favorite(context: context)
            favorite.movieId = movieId
            favorite.timeDate = Date()

            context.save(with: .favoriteMovie)
        }
    }

    func remove(_ movieId: String, in context: NSManagedObjectContext) {
        print("Unfavoriting: \(movieId)")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        guard let favorites = try? context.fetch(fetchRequest) as? [Favorite] else { return }

        if let favoriteToRemove = favorites.first(where: { $0.movieId == movieId }) {
            context.delete(favoriteToRemove)
        }

        context.save(with: .unfavoriteMovie)
    }

    func get() -> [Favorite] {
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        let favorites = try? persistentContainer.viewContext.fetch(fetchRequest)

        return favorites ?? []
    }
}
