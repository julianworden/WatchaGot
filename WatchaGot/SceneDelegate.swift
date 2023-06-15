//
//  SceneDelegate.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/6/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let homeViewController = HomeViewController()
        homeViewController.viewModel = HomeViewModel()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

