//
//  CacheFeedUseCaseTests.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 21/12/21.
//

import Feed
import Foundation
import XCTest

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let images = uniqueImages().model

        sut.save(images) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let images = uniqueImages().model
        let error = anyNSError()

        sut.save(images) { _ in }
        store.completeDeletion(with: error)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let images = uniqueImages()

        sut.save(images.model) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(images.local, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()

        expect(sut, toCompleteWithError: error, when: {
            store.completeDeletion(with: error)
        })
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()

        expect(sut, toCompleteWithError: error, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: error)
        })
    }

    func test_save_succeedsOnSuccesfulCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfuly()
        })
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImages().model) { error in
            receivedErrors.append(error)
        }

        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedErrors.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImages().model) { error in
            receivedErrors.append(error)
        }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedErrors.isEmpty)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut: sut, store: store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        var receivedError: Error?
        sut.save(uniqueImages().model) { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
}
