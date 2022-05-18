//
//  AppDelegate.swift
//  FeedApp
//
//  Created by Julianny Favinha Donda on 05/05/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)

        #if DEBUG
        config.delegateClass = DebuggingSceneDelegate.self
        #endif

        return config
    }
}

