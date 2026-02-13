//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Amin faruq on 21/01/26.
//

import Foundation

/// Concrete `HTTPClient` implementation backed by `URLSession`.
///
/// Responsibilities:
/// - Perform HTTP GET requests using `URLSession`
/// - Map `URLSession` completion values `(data, response, error)` into `HTTPClientResult`
///
/// Notes:
/// - This type does not enforce a specific dispatch queue for the completion; callers should dispatch as needed
/// - Status code validation and JSON decoding are intentionally delegated to higher layers (e.g., mappers/use cases)
public class URLSessionHTTPClient: HTTPClient {
    /// Injected `URLSession` to enable configuration and testing (default: `.shared`).
    private let session: URLSession
    
    /// Creates an HTTP client backed by the provided `URLSession`.
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Internal sentinel error used when `URLSession` returns an unexpected combination of values.
    private struct UnexpectedValuesRepresentation: Error {}
    
    /// Performs an HTTP GET request and completes with `HTTPClientResult`.
    /// - Maps:
    ///   - `error != nil` → `.failure(error)` (transport/request-level failures)
    ///   - `data != nil` and `response is HTTPURLResponse` → `.success(data, response)`
    ///   - otherwise → `.failure(UnexpectedValuesRepresentation())`
    /// - Important: No threading guarantees; the completion may be invoked on an arbitrary queue.
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

