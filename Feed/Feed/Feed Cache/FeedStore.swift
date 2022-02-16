//
//  FeedStore.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 22/12/21.
//

import Foundation

public struct CachedFeed {
    public let feed: [LocalFeedImage]
    public let timestamp: Date

    public init(
        feed: [LocalFeedImage],
        timestamp: Date
    ) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    func insert(_ localFeedImages: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    func retrieve(completion: @escaping RetrievalCompletion)
}
