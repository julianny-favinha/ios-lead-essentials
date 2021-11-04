//
//  FeedLoader.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 04/11/21.
//

import Foundation

enum FeedLoaderResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
