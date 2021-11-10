import Foundation
import XCTest
import Feed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSut()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_once_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSut(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_twice_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSut(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    // MARK: - Private helpers

    private func makeSut(url: URL = URL(string: "https://test-url.com")!) -> (sut: RemoteFeedLoader, httpClientSpy: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut: sut, httpClientSpy: client)
    }

    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs: [URL] = []

        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
