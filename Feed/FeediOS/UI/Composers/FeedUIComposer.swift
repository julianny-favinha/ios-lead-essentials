//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 09/03/22.
//

import Feed
import Foundation
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        loader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: loader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                let viewModel = FeedImageViewModel(
                    model: model,
                    imageLoader: imageLoader,
                    imageTransformer: UIImage.init
                )
                return FeedImageCellController(viewModel: viewModel)
            }
        }

        return feedController
    }
}
