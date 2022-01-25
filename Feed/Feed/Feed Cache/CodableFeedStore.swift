//
//  CodableFeedStore.swift
//  Feed
//
//  Created by Julianny Favinha Donda on 12/01/22.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableLocalFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    private struct CodableLocalFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        var local: LocalFeedImage {
            return .init(id: id, description: description, location: location, url: url)
        }
    }

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func insert(_ localFeedImages: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL

        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let codableLocalFeedImages: [CodableLocalFeedImage] = localFeedImages.map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
                let encoded = try! encoder.encode(Cache(feed: codableLocalFeedImages, timestamp: timestamp))
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL

        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)

                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL

        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
