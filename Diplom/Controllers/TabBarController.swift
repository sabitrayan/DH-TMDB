//
//  TabBarController.swift
//  Diplom
//
//  Created by ryan on 19.11.2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            containerize(for: NowPlayingViewController(), title: "Now Playing", icon: "now_playing"),
            containerize(for: FavoritesViewController(), title: "Favorites", icon: "heart"),
            containerize(for: SearchViewController(), title: "Search", icon: "search"),

        ]
    }

    private func containerize(for vc: UIViewController, title: String, icon: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: vc)

        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: icon)
        navController.navigationBar.prefersLargeTitles = true

        vc.navigationItem.title = title

        return navController
    }

}
