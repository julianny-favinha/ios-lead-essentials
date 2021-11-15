//
//  RemoteFeedLoader.swift
//  
//
//  Created by Julianny Favinha Donda on 10/11/21.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = FeedLoaderResult

    public init(
        client: HTTPClient,
        url: URL
    ) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (FeedLoaderResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success(let httpResponse, let data):
                let result = FeedItemsMapper.map(data, from: httpResponse)
                completion(result)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
