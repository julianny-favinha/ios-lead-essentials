//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 09/03/22.
//

import Feed
import Foundation
import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let feedLoader: FeedLoader

    init(
        feedLoader: FeedLoader
    ) {
        self.feedLoader = feedLoader
    }

    var onRefresh: (([FeedImage]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()

        feedLoader.load { [weak self] result in
            if let images = try? result.get() {
                self?.onRefresh?(images)
            }

            self?.view.endRefreshing()
        }
    }
}
