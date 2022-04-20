//
//  FeedPresenter.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 23/03/22.
//

import Feed
import Foundation

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView

    init(
        feedView: FeedView,
        feedLoadingView: FeedLoadingView
    ) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }

    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "")
    }

    func didStartLoadingFeed() {
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
