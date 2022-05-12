//
//  FeedLoaderCacheDecorator.swift
//  FeedApp
//
//  Created by Julianny Favinha Donda on 11/05/22.
//

import Feed
import Foundation

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache

    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.save(feed) { _ in }
            }

            completion(result)
        }
    }
}
