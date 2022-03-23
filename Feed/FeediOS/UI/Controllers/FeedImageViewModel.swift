//
//  FeedImageViewModel.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 16/03/22.
//

import Feed
import Foundation

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void

    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?

    init(
        model: FeedImage,
        imageLoader: FeedImageDataLoader,
        imageTransformer: @escaping (Data) -> Image?
    ) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    var hasLocation: Bool {
        model.location != nil
    }

    var location: String? {
        model.location
    }

    var description: String? {
        model.description
    }

    var url: URL {
        model.url
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationLabel.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        cell.imageContainer.startShimmering()

        return cell
    }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)

        task = imageLoader.loadImageData(from: url) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }

        onImageLoadingStateChange?(false)
    }

    func cancelImageDataLoad() {
        task?.cancel()
    }
}
