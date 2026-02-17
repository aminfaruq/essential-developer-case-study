//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Amin faruq on 26/12/25.
//

import Foundation

/*
public enum HTTPClientResult {
    /// Request completed successfully with raw payload and HTTP metadata.
    case success(Data, HTTPURLResponse)
    /// Request failed due to transport or request-level error (e.g., connectivity, cancellation, timeout).
    case failure(Error)
}
*/

/// An abstraction over an HTTP client capable of performing GET requests.
///
/// Responsibilities:
/// - Execute a GET request for a given URL
/// - Deliver the result asynchronously via a completion closure
///
/// Contract:
/// - The completion is invoked exactly once per request
/// - The client does not impose threading guarantees; callers should dispatch as needed
/// - The client delivers either a `.success(Data, HTTPURLResponse)` or a `.failure(Error)`
public protocol HTTPClient {
    /// A result type that represents the outcome of an HTTP GET request performed by `HTTPClient`.
    /// - Note: The `success` case returns raw `Data` and the associated `HTTPURLResponse` so callers
    ///   can validate status codes/headers before mapping to domain models.
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// Performs an asynchronous HTTP GET to the specified URL and completes with the raw result.
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
