//
//  MoviesProvider.swift
//  Diplom
//
//  Created by ryan on 10.11.2021.
//

import CoreData

class MoviesProvider {

    private(set) var persistentContainer: NSPersistentContainer


    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest = NSFetchRequest<Movie>(entityName: "Movie")
        fetchRequest.sortDescriptors = [
             NSSortDescriptor(key: "popularity", ascending: false)
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

    var page: Int = 1
    var pageSearch = 1
    var lastPageSearch = 1
    var searchedMovies: [Movie] = []
    var searchTerm = ""


    init(
        with persistentContainer: NSPersistentContainer,
        fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    ) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    func fetchNowPlaying(completionHandler: ((MovieFeed?, Error?) -> Void)? = nil) {
        guard page < 5 else { completionHandler?(nil, nil); return }

        TMDBNetwork.shared.fetchMovies(page: page) { feed, error in
            completionHandler?(feed, error)

            guard let feed = feed else { return }

            do {
                try self.getMovies(from: feed)
                print(feed.results.first!.id)
                self.page += 1
            } catch let importError {
                completionHandler?(nil, importError)
                return
            }
        }
    }

    func fetchSearchPlaying(searchTerm: String?, completionHandler: ((MovieFeed?, Error?) -> Void)? = nil) {
        guard page < 5 else { completionHandler?(nil, nil); return }

        TMDBNetwork.shared.fecthSearch(searchTerm: searchTerm ?? "Avengers") { feed, err in
            guard let feed = feed else { return }
            do {
                try self.getMovies(from: feed)

                self.page += 1
            } catch let importError {
                completionHandler?(nil, importError)
                return
            }
        }
    }

    private func getMovies(from feed: MovieFeed) throws {
        guard !feed.results.isEmpty else { return }

        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        let batchSize = 3
        let count = feed.results.count

        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0

        for batchNumber in 0..<numBatches {
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd

            let moviesBatch = Array(feed.results[range])

            if !importBatch(moviesBatch, taskContext: taskContext) {
                return
            }
        }
    }


    private func importBatch(_ moviesBatch: [MovieFeed.MovieProperties], taskContext: NSManagedObjectContext) -> Bool {
        var success = false


        taskContext.performAndWait {
            for movieData in moviesBatch {

                guard let movie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: taskContext) as? Movie else {
                    print("Failed to create a new Movie object.")
                    return
                }
                do {
                    try movie.update(with: movieData)
                } catch MovieError.missingData {
                    print("Found and will discard a Movie missing data.")
                    taskContext.delete(movie)
                } catch {
                    print(error.localizedDescription)
                }
            }

            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                    return
                }

                taskContext.reset()
            }

            success = true
        }

        return success
    }
}
