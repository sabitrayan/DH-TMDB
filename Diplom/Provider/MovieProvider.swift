//
//  MovieProvider.swift
//  Diplom
//
//  Created by ryan on 10.11.2021.
//

import CoreData

class MovieProvider {

    private(set) var persistentContainer: NSPersistentContainer

    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    lazy var fetchedCastResultsController: NSFetchedResultsController<Cast> = {
        let fetchRequest: NSFetchRequest<Cast> = Cast.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF in %@", movie.cast!)
        fetchRequest.sortDescriptors = [
             NSSortDescriptor(key: "order", ascending: true)
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

    let movie: Movie

    init(
        with persistentContainer: NSPersistentContainer,
        fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?,
        movie: Movie
    ) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.movie = movie
    }

    func fetchCast(for movie: Movie) {
        if movie.cast?.count == 0 {
            TMDBNetwork.shared.fetchCast(movieId: movie.movieId ) { castFeed, error in
                castFeed.cast.forEach {
                    let cast = Cast(context: self.persistentContainer.viewContext)

                    do {
                        try cast.update(with: $0)

                        if !movie.cast!.contains(cast) {
                            movie.addToCast(cast)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

}
