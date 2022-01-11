//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 29/12/21.
//

import XCTest
import Feed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in } 

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()

        expect(sut, toCompleteWith: .failure(error), when: {
            store.completeRetrieval(with: error)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCachedImagesOnNonExpiredOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let noExpiredTimestamp = fixedCurrentDate.minusFeedCache().adding(seconds: 1)

        expect(sut, toCompleteWith: .success(feed.model), when: {
            store.completeRetrieval(with: feed.local, timestamp: noExpiredTimestamp)
        })
    }

    func test_load_deliversNoImagesExactAgeOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let exactTimestamp = fixedCurrentDate.minusFeedCache()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: exactTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreExpiredOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let moreExpiredTimestamp = fixedCurrentDate.minusFeedCache().adding(seconds: -1)

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: moreExpiredTimestamp)
        })
    }

    func test_load_hasNoSideEffectsOnCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnCacheOnNonExpiredOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let noExpiredTimestamp = fixedCurrentDate.minusFeedCache().adding(seconds: 1)

        sut.load { _ in }

        store.completeRetrieval(with: feed.local, timestamp: noExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnCacheExactAgeOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let exactTimestamp = fixedCurrentDate.minusFeedCache()

        sut.load { _ in }

        store.completeRetrieval(with: feed.local, timestamp: exactTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectCacheOnMoreExpiredOldCache() {
        let feed = uniqueImages()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let moreExpiredTimestamp = fixedCurrentDate.minusFeedCache().adding(seconds: -1)

        sut.load { _ in }

        store.completeRetrieval(with: feed.local, timestamp: moreExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load {
            receivedResults.append($0)
        }

        sut = nil

        store.completeRetrievalWithEmptyCache()

        XCTAssertTrue(receivedResults.isEmpty)
    }
}

extension LoadFeedFromCacheUseCaseTests {
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut: sut, store: store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedImages), .success(let expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
