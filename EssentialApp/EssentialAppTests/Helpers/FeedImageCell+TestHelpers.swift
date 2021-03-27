//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
	func simulateRetryAction() {
		feedImageRetryButton.simulateTap()
	}
	
	func simulateTapAction() {
		feedImageButton.simulateTap()
	}
	
	var isShowingLocation: Bool {
		return !locationContainer.isHidden
	}
	
	var isShowingImageLoadingIndicator: Bool {
		return feedImageContainer.isShimmering
	}
	
	var isShowingRetryAction: Bool {
		return !feedImageRetryButton.isHidden
	}
	
	var isShowingImageButton: Bool {
		return !feedImageButton.isHidden
	}
	
	var locationText: String? {
		return locationLabel.text
	}
	
	var descriptionText: String? {
		return descriptionLabel.text
	}
	
	var renderedImage: Data? {
		return feedImageView.image?.pngData()
	}
}
