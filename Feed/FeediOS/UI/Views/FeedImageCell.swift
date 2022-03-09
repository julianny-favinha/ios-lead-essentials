//
//  FeedImageCell.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 02/03/22.
//

import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc func retryButtonTapped() {
        onRetry?()
    }
}
