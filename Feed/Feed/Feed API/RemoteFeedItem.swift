//
//  RemoteFeedItem.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 22/12/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL

    var feedItem: FeedImage {
        return FeedImage(id: id, description: description, location: location, url: image)
    }
}
