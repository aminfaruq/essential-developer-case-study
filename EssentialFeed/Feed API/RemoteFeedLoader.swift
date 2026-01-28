//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 23/12/25.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    /// Domain-specific error categories exposed by `RemoteFeedLoader`.
    /// - `connectivity`: Underlying transport/request error from the HTTP client (e.g., no internet, timeout, cancellation).
    /// - `invalidData`: Received an HTTP response that failed validation (non-200) or the payload could not be decoded into domain models.
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load( completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

