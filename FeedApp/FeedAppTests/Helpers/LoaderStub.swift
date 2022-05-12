//
//  LoaderStub.swift
//  FeedAppTests
//
//  Created by Julianny Favinha Donda on 11/05/22.
//

import Feed
import Foundation

class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
