//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 22/12/25.
//

import Foundation

/*public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}*/

/// A use-case abstraction that loads the feed asynchronously.
///
/// Contract:
/// - The completion is invoked exactly once per call
/// - No threading guarantees; callers should dispatch as needed
/// - Implementations may source data from network, cache, or composites
public protocol FeedLoader {
    /// Result of a feed loading operation.
    /// - `.success([FeedImage])`: The loader produced a list of domain items
    /// - `.failure(Error)`: The loader failed with a domain-relevant error
    typealias Result = Swift.Result<[FeedImage], Error>

    /// Starts loading the feed and completes with `LoadFeedResult`.
    func load(completion: @escaping (Result) -> Void)
}
