//
//  FeedImage.swift
//  EssentialFeed
//
//  Created by Amin faruq on 22/12/25.
//

import Foundation

/// A pure domain model representing a single feed item.
///
/// This type is intentionally infrastructure-agnostic (no networking/UI/storage concerns)
/// and models the minimal truth the app relies on:
/// - `id`: unique identity
/// - `description` and `location`: optional metadata
/// - `url`: the canonical image location
///
/// Conforms to `Equatable` to enable reliable comparisons in tests and app logic
/// (e.g., asserting expected results, detecting changes, removing specific items).
public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    /// Creates a new immutable feed item. All properties are required except `description` and `location`.
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

