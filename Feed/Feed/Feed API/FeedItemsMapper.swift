//
//  FeedItemsMappter.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 15/11/21.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let image: URL

        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    private enum HttpCodes: Int {
        case ok = 200
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == HttpCodes.ok.rawValue else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.feedItem }
    }
}
