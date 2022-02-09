//
//  FeedLoader.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 04/11/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
