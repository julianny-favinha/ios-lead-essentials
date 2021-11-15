//
//  RemoteFeedLoader.swift
//  
//
//  Created by Julianny Favinha Donda on 10/11/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(
        client: HTTPClient,
        url: URL
    ) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let httpResponse, let data):
//                completion(self.map(data, from: httpResponse))
                do {
                    let items = try FeedItemsMapper.map(data, httpResponse)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

    private func map(_ data: Data, from httpResponse: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, httpResponse)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
