//
//  BookSearchCoordinator.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import UIKit
import ReactorKit

@MainActor
final class BookSearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let bookmarkRepository = CoreDataBookmarkRepository()
    private let recentBookRepository = CoreDataRecentBookRepository()
    private let bookRepository: BookRepositoryProtocol

    init(
        navigationController: UINavigationController,
        bookRepository: BookRepositoryProtocol? = nil
    ) {
        self.navigationController = navigationController
        self.bookRepository = bookRepository ?? BookRepository(dataSource: BookDataSource())
    }

    func start() {
        let viewController = BookSearchViewController()
        viewController.coordinator = self
        viewController.reactor = BookSearchViewReactor(
            searchBookUseCase: SearchBookUseCase(reporitory: bookRepository),
            fetchRecentBooksUseCase: FetchRecentBooksUseCase(repository: recentBookRepository)
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
