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

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_twice_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSut(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSut()

        [199, 201, 300, 404, 500].enumerated().forEach { index, statusCode in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }

            client.complete(with: statusCode, at: index)

            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSut()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: - Private helpers

    private func makeSut(url: URL = URL(string: "https://test-url.com")!) -> (sut: RemoteFeedLoader, httpClientSpy: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut: sut, httpClientSpy: client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        var completions: [(HTTPClientResult) -> Void] {
            messages.map { $0.completion }
        }

        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url: url, completion: completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(with statusCode: Int, at index: Int = 0) {
            let httpURLResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )

            messages[index].completion(.success(httpURLResponse!))
        }
    }
}
