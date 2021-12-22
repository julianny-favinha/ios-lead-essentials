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

    private func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let images = [
            FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://any.com")!),
            FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://any.com")!)
        ]

        let local = images.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

        return (model: images, local: local)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        var receivedError: Error?
        sut.save(uniqueImages().model) { error in
            receivedError = error
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError)
    }

    private func anyNSError() -> NSError {
        .init(domain: "", code: 0, userInfo: nil)
    }
}

extension CacheFeedUseCaseTests {
    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([LocalFeedImage], Date)
        }

        private(set) var receivedMessages = [ReceivedMessage]()

        private var deletionCompletions = [DeletionCompletion]()

        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }

        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }

        typealias InsertionCompletion = (LocalFeedLoader.SaveResult) -> Void
        private var insertionCompletions = [InsertionCompletion]()

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }

        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }

        func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(images, timestamp))
        }

        func completeInsertionSuccessfuly(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
