//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Amin faruq on 26/12/25.
//

import Foundation

/// Maps raw HTTP payloads into domain `[FeedItem]` while enforcing transport and schema constraints.
///
/// Responsibilities:
/// - Accept an HTTP response and its raw `Data`
/// - Validate the HTTP status code (200-only)
/// - Decode the expected JSON payload into internal DTOs
/// - Map DTOs into the pure domain model `FeedItem`
///
/// Contract:
/// - Returns `.success([FeedItem])` when `statusCode == 200` and decoding succeeds
/// - Returns `.failure(.invalidData)` for any other combination (non-200 or invalid JSON)
///
/// Expected JSON shape:
/// {
///   "items": [
///     {
///       "id": "<uuid>",
///       "description": "<optional string>",
///       "location": "<optional string>",
///       "image": "<url>"
///     }
///   ]
/// }
internal final class FeedItemsMapper {
    
    /// Top-level payload that wraps an array of `Item` DTOs.
    private struct Root: Decodable {
        let items: [Item]
        
        /// Transforms decoded DTOs into domain models.
        var feed: [FeedItem] {
            return items.map({ $0.item })
        }
    }
    
    /// Data Transfer Object (DTO) that mirrors the JSON fields for a single feed entry.
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        /// Maps this DTO into the domain `FeedItem`.
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
     
    /// Only HTTP 200 responses are considered valid for mapping.
    static var OK_200: Int { return 200 }
    
    /// Maps `(data, response)` into `RemoteFeedLoader.Result`.
    /// - Requires: `response.statusCode == 200` and a JSON payload matching `Root`.
    /// - Returns: `.success([FeedItem])` on valid input; otherwise `.failure(.invalidData)`.
    ///
    /// Examples:
    /// - Valid (status 200):
    ///   {
    ///     "items": [
    ///       {
    ///         "id": "A1B2C3D4-E5F6-7890-1234-56789ABCDEF0",
    ///         "description": "optional text",
    ///         "location": null,
    ///         "image": "https://example.com/image.png"
    ///       }
    ///     ]
    ///   }
    /// - Invalid (non-200 status): any payload with status != 200
    /// - Invalid (malformed JSON or missing required fields):
    ///   {
    ///     "items": [ { "description": "missing id & image" } ]
    ///   }
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}

