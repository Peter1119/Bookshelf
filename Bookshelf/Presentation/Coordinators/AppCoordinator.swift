//
//  AppCoordinator.swift
//  Bookshelf
//
//  Created by 홍석현 on 10/31/25.
//

import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
