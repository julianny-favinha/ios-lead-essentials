//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Julianny Favinha Donda on 02/02/22.
//

import Feed
import XCTest

class FeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }

    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toLoad: [])
    }

    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImages().model

        save(feed, with: sutToPerformSave)

        expect(sutToPerformLoad, toLoad: feed)
    }

    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImages().model
        let secondFeed = uniqueImages().model

        save(firstFeed, with: sutToPerformFirstSave)
        save(secondFeed, with: sutToPerformSecondSave)

        expect(sutToPerformLoad, toLoad: secondFeed)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func expect(_ sut: LocalFeedLoader, toLoad feedImages: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load")

        sut.load { result in
            switch result {
            case let .success(receivedFeedImages):
                XCTAssertEqual(receivedFeedImages, feedImages, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func save(_ feedImages: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save")

        sut.save(feedImages) { error in
            XCTAssertNil(error, file: file, line: line)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
