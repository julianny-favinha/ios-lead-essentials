//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 11/01/22.
//

import XCTest
import Feed

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()

        cleanFileManager()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesIOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = dummyStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        let error = anyNSError()

        try! "invalid data".write(to: dummyStoreURL(), atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(error))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = dummyStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        let error = anyNSError()

        try! "invalid data".write(to: dummyStoreURL(), atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(error))
    }

    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makeSUT()

        let firstFeed = uniqueImages().local
        let firstTimestamp = Date()
        insert(feed: firstFeed, timestamp: firstTimestamp, to: sut)

        let latestFeed = uniqueImages().local
        let latestTimestamp = Date()
        insert(feed: latestFeed, timestamp: latestTimestamp, to: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "https://invalidurl.com")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImages().local
        let timestamp = Date()

        let error = insert(feed: feed, timestamp: timestamp, to: sut)

        XCTAssertNotNil(error)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNil(receivedError)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNil(receivedError)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNotNil(receivedError)
    }
}

extension CodableFeedStoreTests {
    private func dummyStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? dummyStoreURL())

        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }

    private func cleanFileManager() {
        try? FileManager.default.removeItem(at: dummyStoreURL())
    }

    @discardableResult
    private func insert(feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for completion")

        var error: Error?
        sut.insert(feed, timestamp: timestamp) { insertError in
            error = insertError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return error
    }

    private func deleteCachedFeed(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for completion")

        var receivedError: Error?
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return receivedError
    }

    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")

        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(receivedFeed, receivedTimestamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) result, got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
