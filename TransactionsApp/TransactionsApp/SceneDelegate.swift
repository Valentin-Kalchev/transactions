//
//  SceneDelegate.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit
import TransactionsEngine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow? 

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "http://www.mocky.io/v2/5b36325b340000f60cf88903")!
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let loader = RemoteTransactionsLoader(url: url, client: client)
        window?.rootViewController = TransactionsUIComposer.viewController(loader: loader)
        window?.makeKeyAndVisible()
    }

}

