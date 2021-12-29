//
//  FeedStore.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 22/12/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    typealias InsertionCompletion = (Error?) -> Void
    func insert(_ localFeedImages: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    func retrieve(completion: @escaping RetrievalCompletion)
}
