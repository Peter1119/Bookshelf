//
//  BookmarkCoordinator.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import UIKit
import ReactorKit

@MainActor
final class BookmarkCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let bookmarkRepository = CoreDataBookmarkRepository()
    private let recentBookRepository = CoreDataRecentBookRepository()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = BookmarkListViewController()
        viewController.coordinator = self
        viewController.reactor = BookmarkListViewReactor(
            fetchBookmarksUseCase: FetchBookmarksUseCase(repository: bookmarkRepository),
            removeBookmarkUseCase: RemoveBookmarkUseCase(repository: bookmarkRepository)
        )
        navigationController.pushViewController(viewController, animated: false)
    }

    func showBookDetail(book: Book) {
        let detailVC = BookDetailViewController()
        detailVC.reactor = BookDetailViewReactor(
            book: book,
            addBookmarkUseCase: AddBookmarkUseCase(repository: bookmarkRepository),
            removeBookmarkUseCase: RemoveBookmarkUseCase(repository: bookmarkRepository),
            checkBookmarkUseCase: CheckBookmarkUseCase(repository: bookmarkRepository),
            saveRecentBookUseCase: SaveRecentBookUseCase(repository: recentBookRepository)
        )

        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        navigationController.present(navController, animated: true)
    }
}
