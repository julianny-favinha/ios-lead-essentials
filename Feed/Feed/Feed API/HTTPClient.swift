//
//  HTTPClient.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 10/11/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
