//
//  FeedImagePresenterTests.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 04/05/22.
//

import Foundation
import Feed
import XCTest

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_didStartLoadingImageData_shouldDisplayView() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()

        sut.didStartLoadingImageData(for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
    }

    func test_didFinishLoadingImageData_withData_shouldDisplayView() {
        let anyImage = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in anyImage })
        let data = Data()
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: data, for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, anyImage)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
    }

    func test_didFinishLoadingImageData_withImageError_shouldDisplayView() {
        let (sut, view) = makeSUT()
        let data = Data()
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: data, for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }

    func test_didFinishLoadingImageData_withError_shouldDisplayView() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: error, for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }

    // MARKER: - Helpers

    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil}, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter(view: viewSpy, imageTransformer: imageTransformer)

        trackForMemoryLeaks(viewSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, viewSpy)
    }

    private struct AnyImage: Equatable {}

    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()

        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
