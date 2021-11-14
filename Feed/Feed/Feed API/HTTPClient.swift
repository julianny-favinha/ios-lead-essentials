//
//  HTTPClient.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 10/11/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
