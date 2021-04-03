//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class ImageCommentsListPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty)
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
	}
	
	func test_didFinishLoadingCommentsWithComments_stopsLoadingAndDisplaysComments() {
		let (sut, view) = makeSUT()
		let comments = makeComments()
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [.display(isLoading: false), .display(comments: comments)])
	}
	
	func test_didFinishLoadingFeedWithError_stopsLoadingAndDisplaysLocalizedErrorMessage() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("IMAGE_COMMENTS_VIEW_ERROR_MESSAGE"))])
	}
	
	func test_viewModel_mapsCommentToViewModelWithRelativeDateFormatting() {
		let staticDate = dateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		let samples: [(comment: ImageComment, relativeDate: String)] = [
			(comment(date: dateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000")), "2 hours ago"),
			(comment(date: dateFromTimestamp(1_605_713_544, description: "2020-11-18 15:32:24 +0000")), "1 day ago"),
			(comment(date: dateFromTimestamp(1_604_571_429, description: "2020-11-05 10:17:09 +0000")), "2 weeks ago"),
			(comment(date: dateFromTimestamp(1_602_510_149, description: "2020-10-12 13:42:29 +0000")), "1 month ago"),
			(comment(date: dateFromTimestamp(1_488_240_000, description: "2017-02-28 00:00:00 +0000")), "3 years ago")
		]
		
		samples.enumerated().forEach { index, pair in
			let (comment, relativeDate) = pair
			let (sut, _) = makeSUT(currentDate: { staticDate })
			
			let viewModel = sut.viewModel(for: comment)
			
			XCTAssertEqual(viewModel.author, comment.author)
			XCTAssertEqual(viewModel.message, comment.message)
			XCTAssertEqual(viewModel.creationDate, relativeDate)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(currentDate: currentDate, loadingView: view, commentsView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func dateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		let date = Date(timeIntervalSince1970: timestamp)
		XCTAssertEqual(date.description, description, file: file, line: line)
		return date
	}
	
	func makeComments() -> [ImageComment] {
		return [comment(date: Date()), comment(date: Date())]
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsListPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsListView, ImageCommentsErrorView {
		enum Messages: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
		}
		
		private(set) var messages = Set<Messages>()
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsListViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
	}
}


