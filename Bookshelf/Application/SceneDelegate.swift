//
//  SceneDelegate.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/27/25.
//

import UIKit
import ReactorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let viewController = BookSearchViewController()
        viewController.reactor = BookSearchViewReactor(
            searchBookUseCase: SearchBookUseCase(
                reporitory: BookRepository(
                    dataSource: BookDataSource()
                )
            ),
            fetchRecentBooksUseCase: FetchRecentBooksUseCase(
                repository: MockBookRepository()
            )
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

