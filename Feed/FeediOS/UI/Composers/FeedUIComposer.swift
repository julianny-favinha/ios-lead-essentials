//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 09/03/22.
//

import Feed
import Foundation

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        loader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: loader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }

        return feedController
    }
}
