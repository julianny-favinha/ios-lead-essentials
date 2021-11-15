//
//  HTTPClientResult.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 15/11/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}
