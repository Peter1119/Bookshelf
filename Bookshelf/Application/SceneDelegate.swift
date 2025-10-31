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
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator

        Task { @MainActor in
            coordinator.start()
        }
    }
}

