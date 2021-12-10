//
//  FavoritesViewController.swift
//  Diplom
//
//  Created by ryan on 19.11.2021.
//

import UIKit
import CoreData

class FavoritesViewController: UICollectionViewController {

    private lazy var moviesProvider: MoviesProvider = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        return MoviesProvider(
            with: appDelegate!.coreDataStack.persistentContainer,
            fetchedResultsControllerDelegate: self
        )
    }()

    private lazy var favoritesProvider: FavoritesProvider = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        return FavoritesProvider(
            with: appDelegate!.coreDataStack.persistentContainer,
            fetchedResultsControllerDelegate: self
        )
    }()

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let favoritedMovieIds = favoritesProvider.get().map { $0.movieId }
        let filterPredicate = NSPredicate(format: "movieId in %@", favoritedMovieIds)
        moviesProvider.fetchedResultsController.fetchRequest.predicate = filterPredicate

        do {
            try moviesProvider.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }

        collectionView.reloadData()
    }

    private func setupUI() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.cellId)
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FavoritesViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.cellId, for: indexPath) as! MovieCell
        guard let movie = moviesProvider.fetchedResultsController.fetchedObjects?[indexPath.item] else {
            return cell
        }

        cell.movie = movie

        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 104, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 24, right: 0)
    }
}

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
