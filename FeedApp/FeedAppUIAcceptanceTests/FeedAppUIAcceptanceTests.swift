//
//  FeedAppUIAcceptanceTests.swift
//  FeedAppUIAcceptanceTests
//
//  Created by Julianny Favinha Donda on 18/05/22.
//

import XCTest

final class FeedAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_shouldFetchRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        onlineApp.launch()

        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)

        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }

    func test_onLaunch_displaysEmptyFeedWhenNoConnectivityAndNoCache() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "offline"]  // reset pra não haver testes influenciando um no outro
        offlineApp.launch()

        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
