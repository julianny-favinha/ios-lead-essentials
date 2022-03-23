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
        let presenterAdapter = FeedLoaderPresentationAdapter(feedLoader: loader)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)

        let feedLoadingView = WeakRefVirtualProxy(refreshController)
        let feedView = FeedImageAdapter(controller: feedController, imageLoader: imageLoader)

        let presenter = FeedPresenter(
            feedView: feedView,
            feedLoadingView: feedLoadingView
        )

        presenterAdapter.presenter = presenter

        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

private final class FeedImageAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let viewModel = FeedImageViewModel(
                model: model,
                imageLoader: imageLoader,
                imageTransformer: UIImage.init
            )
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
