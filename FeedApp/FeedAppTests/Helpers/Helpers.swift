//
//  Helpers.swift
//  FeedAppTests
//
//  Created by Julianny Favinha Donda on 11/05/22.
//

import Feed
import Foundation

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any.com")!)]
}

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0, userInfo: nil)
}
