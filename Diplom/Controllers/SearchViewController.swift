//
//  SearchViewController.swift
//  Diplom
//
//  Created by ryan on 22.11.2021.
//

import UIKit

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    fileprivate let cellId = "id1234"
    fileprivate let  searchController = UISearchController(searchResultsController: nil)

    fileprivate let enterSearchTermLabel : UILabel = {
        $0.text = "Please enter search term movie"
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        return $0
    }(UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor  = .white
        collectionView.register(SearchViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.addSubview(enterSearchTermLabel)
        enterSearchTermLabel.fillSuperview(padding: .init(top: 100, left: 50, bottom: 0, right: 50))
        setupSearchBar()

        moviesServies()
    }

        fileprivate func setupSearchBar() {
            definesPresentationContext = true
            navigationItem.searchController = self.searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.delegate = self
        }

        var timer: Timer?

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            timer?.invalidate()

            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in TMDBNetwork.shared.fecthSearch(searchTerm: searchText) { (res, err) in
                            if let err = err {
                                print("Faied to search result", err)
                                return
                            }

                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }

                        }
            })

        }
    fileprivate var appResults = [Results]()
    func moviesServies() {
        TMDBNetwork.shared.fecthSearch(searchTerm: "Avengers") { results, err in
            if let err = err {
                print("Failed to fetch apps:", err)
                return
            }
            //self.appResults = results
    //                reload data
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 350)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        enterSearchTermLabel.isHidden = appResults.count != 0

        return appResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchViewCell

            cell.appResult = appResults[indexPath.item]

        return cell
    }
}
