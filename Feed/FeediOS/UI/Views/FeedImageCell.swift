//
//  FeedImageCell.swift
//  FeediOS
//
//  Created by Julianny Favinha Donda on 02/03/22.
//

import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!

    var onRetry: (() -> Void)?

    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}
