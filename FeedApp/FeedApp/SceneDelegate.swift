//
//  SceneDelegate.swift
//  FeedApp
//
//  Created by Julianny Favinha Donda on 05/05/22.
//

import CoreData
import Feed
import FeediOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let client = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        window?.rootViewController = FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader
                ),
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: remoteImageLoader,
                fallback: localImageLoader
            )
        )
    }

    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}
