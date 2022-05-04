//
//  FeedImageCellController.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 09/03/22.
//

import Feed
import Foundation
import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse() 
        delegate.didCancelImageRequest()
    }

    func releaseCellForReuse() {
        cell = nil
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = viewModel.image
        cell?.imageContainer.isShimmering = viewModel.isLoading
        cell?.retryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
}
