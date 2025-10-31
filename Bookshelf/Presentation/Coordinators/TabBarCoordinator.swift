//
//  TabBarCoordinator.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import UIKit

@MainActor
final class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let tabBarController: UITabBarController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }

    func start() {
        let searchNavController = UINavigationController()
        let searchCoordinator = BookSearchCoordinator(navigationController: searchNavController)
        addChild(searchCoordinator)
        searchCoordinator.start()
        searchNavController.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        let bookmarkNavController = UINavigationController()
        let bookmarkCoordinator = BookmarkCoordinator(navigationController: bookmarkNavController)
        addChild(bookmarkCoordinator)
        bookmarkCoordinator.start()
        bookmarkNavController.tabBarItem = UITabBarItem(
            title: "담은 책",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        tabBarController.viewControllers = [searchNavController, bookmarkNavController]
        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
