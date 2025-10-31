//
//  MainTabBarController.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/30/25.
//

import UIKit
import ReactorKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    private func setupViewControllers() {
        let repository = CoreDataBookmarkRepository()
        let bookRepository = BookRepository(dataSource: BookDataSource())
        // 1. 책 검색 탭
        let searchVC = BookSearchViewController()
        searchVC.reactor = BookSearchViewReactor(
            searchBookUseCase: SearchBookUseCase(reporitory: bookRepository),
            fetchRecentBooksUseCase: FetchRecentBooksUseCase(repository: bookRepository)
        )
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        // 2. 담은 책 탭
        let bookmarkVC = BookmarkListViewController()
        bookmarkVC.reactor = BookmarkListViewReactor(
            fetchBookmarksUseCase: FetchBookmarksUseCase(repository: repository)
        )
        let bookmarkNav = UINavigationController(rootViewController: bookmarkVC)
        bookmarkNav.tabBarItem = UITabBarItem(
            title: "담은 책",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        viewControllers = [searchNav, bookmarkNav]
    }
}

@available(iOS 17.0, *)
#Preview {
    MainTabBarController()
}
