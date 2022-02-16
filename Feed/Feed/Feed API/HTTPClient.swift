//
//  HTTPClient.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 10/11/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
