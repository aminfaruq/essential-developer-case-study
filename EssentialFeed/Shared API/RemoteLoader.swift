//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 29/04/26.
//

import Foundation

public final class RemoteLoader<Resource> {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    
    /// Domain-specific error categories exposed by `RemoteFeedLoader`.
    /// - `connectivity`: Underlying transport/request error from the HTTP client (e.g., no internet, timeout, cancellation).
    /// - `invalidData`: Received an HTTP response that failed validation (non-200) or the payload could not be decoded into domain models.
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load( completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
