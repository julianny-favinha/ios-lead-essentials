//
//  FeedImageCellController.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 09/03/22.
//

import Feed
import Foundation
import UIKit

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?

    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(
        model: FeedImage,
        imageLoader: FeedImageDataLoader
    ) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationLabel.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        cell.imageContainer.startShimmering()
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.imageContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }

    func cancelLoad() {
        task?.cancel()
    }
}
