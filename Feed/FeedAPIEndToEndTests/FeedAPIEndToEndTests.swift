//
//  FeedAPIEndToEndTests.swift
//  FeedAPIEndToEndTests
//
//  Created by Julianny Favinha Donda on 17/11/21.
//

import Feed
import XCTest

class FeedAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedLoaderResult() {
        case .success(let feedItems)?:
            XCTAssertEqual(feedItems.count, 8)
            // TODO assert the feedItems content too
        case .failure(let error)?:
            XCTFail("Expected success result, got \(error)")
        default:
            XCTFail("Expected success, get not result")
        }
    }
}

extension FeedAPIEndToEndTests {
    private func getFeedLoaderResult(file: StaticString = #file, line: UInt = #line) -> FeedLoaderResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: url)

        trackForMamoryLeaks(client, file: file, line: line)
        trackForMamoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")

        var receivedResult: FeedLoaderResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }
}
