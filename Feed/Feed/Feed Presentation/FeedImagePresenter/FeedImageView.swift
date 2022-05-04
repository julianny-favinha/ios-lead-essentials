//
//  FeedImageView.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 04/05/22.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}
