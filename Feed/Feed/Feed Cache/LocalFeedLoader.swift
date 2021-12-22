//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 22/12/21.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    public typealias SaveResult = Error?

    public init(
        store: FeedStore,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ feedImages: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.insert(feedImages, with: completion)
            }
        }
    }

    private func insert(_ feedImages: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feedImages.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
