//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 25/01/22.
//

import Feed
import Foundation
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let error = anyNSError()

        try! "invalid data".write(to: dummyStoreURL(), atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(error), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let error = anyNSError()

        try! "invalid data".write(to: dummyStoreURL(), atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(error), file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstFeed = uniqueImages().local
        let firstTimestamp = Date()
        insert(feed: firstFeed, timestamp: firstTimestamp, to: sut)

        let latestFeed = uniqueImages().local
        let latestTimestamp = Date()
        insert(feed: latestFeed, timestamp: latestTimestamp, to: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNil(receivedError, file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        deleteCachedFeed(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNil(receivedError, file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImages().local
        let timestamp = Date()

        insert(feed: feed, timestamp: timestamp, to: sut)

        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNil(receivedError, file: file, line: line)
    }

    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let receivedError = deleteCachedFeed(from: sut)

        XCTAssertNotNil(receivedError, file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCachedFeed(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperations = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImages().local, timestamp: Date()) { _ in
            completedOperations.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed() { _ in
            completedOperations.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImages().local, timestamp: Date()) { _ in
            completedOperations.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperations, [op1, op2, op3], file: file, line: line)
    }

    private func dummyStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }

    @discardableResult
    func insert(feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for completion")

        var error: Error?
        sut.insert(feed, timestamp: timestamp) { insertError in
            error = insertError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return error
    }

    @discardableResult
    func deleteCachedFeed(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for completion")

        var receivedError: Error?
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return receivedError
    }

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
