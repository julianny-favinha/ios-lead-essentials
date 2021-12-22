//
//  FeedLoader.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 04/11/21.
//

import Foundation

public enum FeedLoaderResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
