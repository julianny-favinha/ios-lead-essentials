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
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(with: statusCode, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSut()

        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSut()

        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data()
            client.complete(with: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSut()

        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(with: 200, data: emptyListJSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSut()

        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url2.com")!)

        expect(sut, toCompleteWithResult: .success([item1.model, item2.model]), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(with: 200, data: json)
        })
    }

    func test_load_doesNotDeliverResultAfterSutInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(with: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
}

extension RemoteFeedLoaderTests {
    private func makeSut(url: URL = URL(string: "https://test-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, httpClientSpy: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)

        trackForMamoryLeaks(sut, file: file, line: line)
        trackForMamoryLeaks(client, file: file, line: line)

        return (sut: sut, httpClientSpy: client)
    }

    private func trackForMamoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [result])
    }

    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let model = FeedItem(id: id, description: description, location: location, imageURL: imageURL)

        let json = [
            "id": model.id.uuidString,
            "description": model.description,
            "location": model.location,
            "image": model.imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }

        return (model, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]

        return try! JSONSerialization.data(withJSONObject: json)
    }
}

extension RemoteFeedLoaderTests {
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

        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let httpURLResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )

            messages[index].completion(.success(httpURLResponse!, data))
        }
    }
}
