//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

struct ImageCommentLoadingViewModel {
	let isLoading: Bool
}

protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

struct ImageCommentsListViewModel {
	let comments: [ImageComment]
}

protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

struct ImageCommentErrorViewModel {
	let message: String?
}

protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

final class ImageCommentsListPresenter {
	private let loadingView: ImageCommentLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentErrorView
	
	init(loadingView: ImageCommentLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentErrorView) {
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentErrorViewModel(message: nil))
	}
	
	func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
	
	func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentErrorViewModel(message: "Couldn't connect to server"))
	}
}

protocol ImageCommentsRefreshViewControllerDelegate {
	func didRequestLoadingComments()
}

final class ImageCommentsRefreshController: NSObject, ImageCommentLoadingView, ImageCommentErrorView {
	private(set) lazy var refreshView: UIRefreshControl = makeRefreshControl()
	private(set) lazy var errorView: CommentErrorView = makeErrorView()
	
	private let delegate: ImageCommentsRefreshViewControllerDelegate
	
	init(delegate: ImageCommentsRefreshViewControllerDelegate) {
		self.delegate = delegate
	}
	
	@objc
	func refreshComments() {
		delegate.didRequestLoadingComments()
	}
	
	func display(_ viewModel: ImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshView.beginRefreshing()
		} else {
			refreshView.endRefreshing()
		}
	}
	
	func display(_ viewModel: ImageCommentErrorViewModel) {
		if let message = viewModel.message {
			errorView.show(message: message)
		} else {
			errorView.hideMessage()
		}
	}
	
	private func makeRefreshControl() -> UIRefreshControl {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(refreshComments), for: .valueChanged)
		return control
	}
	
	private func makeErrorView() -> CommentErrorView {
		let view = CommentErrorView()
		return view
	}
}