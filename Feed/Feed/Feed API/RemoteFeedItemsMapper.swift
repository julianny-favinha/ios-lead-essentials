//
//  RemoteFeedItemsMapper.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 15/11/21.
//

import Foundation

final class RemoteFeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from httpResponse: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard httpResponse.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
