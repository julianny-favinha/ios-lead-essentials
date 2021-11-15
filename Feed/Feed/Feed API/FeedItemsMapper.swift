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

        var feedItems: [FeedItem] {
            return items.map { $0.feedItem }
        }
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

    static func map(_ data: Data, from httpResponse: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard httpResponse.statusCode == HttpCodes.ok.rawValue,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feedItems)
    }
}
