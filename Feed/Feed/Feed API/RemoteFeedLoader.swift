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

    public init(
        client: HTTPClient,
        url: URL
    ) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
