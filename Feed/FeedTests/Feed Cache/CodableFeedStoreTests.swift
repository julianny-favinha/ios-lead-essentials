//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 11/01/22.
//

import XCTest
import Feed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    override func setUp() {
        super.setUp()

        cleanFileManager()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = dummyStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = dummyStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCache(on: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "https://invalidurl.com")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImages().local
        let timestamp = Date()

        let error = insert(feed: feed, timestamp: timestamp, to: sut)

        XCTAssertNotNil(error)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "https://invalidurl.com")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let receivedError = deleteCachedFeed(from: sut)

        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        assertSideEffectsRunSerially(on: sut)
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
}
