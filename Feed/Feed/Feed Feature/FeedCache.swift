//
//  FeedCache.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 11/05/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
