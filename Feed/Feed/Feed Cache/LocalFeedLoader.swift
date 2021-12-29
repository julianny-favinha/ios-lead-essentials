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
    public typealias LoadResult = FeedLoaderResult

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

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .found(let feed, let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .found, .empty:
                self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            case .failure(let error):
                self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
            }
        }
    }

    // MARK: Private methods

    private func insert(_ feedImages: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feedImages.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let maxCacheAgeInDays = 7

        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }

        return currentDate() < maxCacheAge
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
