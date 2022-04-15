//
//  FeedImageViewModel.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 16/03/22.
//

import Feed
import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
