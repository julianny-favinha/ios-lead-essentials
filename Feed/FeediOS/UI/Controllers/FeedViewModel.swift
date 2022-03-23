//
//  FeedViewModel.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 16/03/22.
//

import Feed
import Foundation

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChanged: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChanged?(true)

        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }

            self?.onLoadingStateChanged?(false)
        }
    }
}
