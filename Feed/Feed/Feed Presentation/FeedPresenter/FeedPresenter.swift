//
//  FeedPresenter.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 27/04/22.
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public struct FeedLoadingViewModel {
    public let isLoading: Bool

    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

public struct FeedErrorViewModel {
    public let message: String?

    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    public static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    public init(
        feedView: FeedView,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView
    ) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "")
    }

    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server"
        )
    }

    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(viewModel: .init(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: .init(feed: feed))
        loadingView.display(viewModel: .init(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(viewModel: .init(isLoading: false))
    }
}
