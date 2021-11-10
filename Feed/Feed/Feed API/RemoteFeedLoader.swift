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

    public init(
        client: HTTPClient,
        url: URL
    ) {
        self.client = client
        self.url = url
    }

    public func load() {
        client.get(from: url)
    }
}
