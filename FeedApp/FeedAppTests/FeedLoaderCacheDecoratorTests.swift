//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Julianny Favinha Donda on 11/05/22.
//

import Feed
import FeedApp
import Foundation
import XCTest

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()

        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let sut = makeSUT(loaderResult: .failure(error))

        expect(sut, toCompleteWith: .failure(error))
    }

    func test_load_cachesFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cache = CacheSpy()

        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [.save(feed)])
    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let error = anyNSError()
        let sut = makeSUT(loaderResult: .failure(error), cache: cache)

        sut.load { _ in }

        XCTAssertTrue(cache.messages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init()) -> FeedLoader {
        let loader = LoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)

        return sut
    }

    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save([FeedImage])
        }

        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
