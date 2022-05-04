//
//  CacheFeedTestHelpers.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 29/12/21.
//

import Feed
import Foundation

func uniqueImage() -> FeedImage {
    FeedImage(
        id: UUID(),
        description: "description", location: "location",
        url: URL(string: "https://any.com")!
    )
}

func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let images = [
        FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://any.com")!),
        FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://any.com")!)
    ]

    let local = images.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

    return (model: images, local: local)
}
