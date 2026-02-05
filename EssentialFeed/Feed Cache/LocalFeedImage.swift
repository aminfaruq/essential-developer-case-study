//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/02/26.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
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
