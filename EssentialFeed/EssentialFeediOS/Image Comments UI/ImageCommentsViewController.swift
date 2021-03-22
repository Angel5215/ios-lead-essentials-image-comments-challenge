//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public class ImageCommentCell: UITableViewCell {
	public let authorLabel = UILabel()
	public let creationDateLabel = UILabel()
	public let messageLabel = UILabel()
}

public class CommentErrorView: UIView {
	private let label = UILabel()
	
	public var message: String? {
		get { return label.text }
		set { label.text = newValue }
	}
}

public class ImageCommentsViewController: UITableViewController {
	private var url: URL!
	private var currentDate: (() -> Date)!
	private var loader: ImageCommentLoader?
	private var task: ImageCommentLoaderTask?
	public let errorView = CommentErrorView()
	
	private var tableModel = [ImageComment]()
	
	public convenience init(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) {
		self.init()
		self.url = url
		self.currentDate = currentDate
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		self.errorView.message = nil
		task = loader?.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.tableModel = comments
				self?.tableView.reloadData()
			case .failure:
				self?.errorView.message = "Couldn't connect to server"
			}
			self?.refreshControl?.endRefreshing()
			self?.task = nil
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cell = ImageCommentCell()
		cell.authorLabel.text = cellModel.author
		cell.messageLabel.text = cellModel.message
		cell.creationDateLabel.text = formatRelativeDate(for: cellModel.creationDate)
		return cell
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}

