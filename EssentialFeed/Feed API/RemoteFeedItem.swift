//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/02/26.
//

import Foundation

/// Data Transfer Object (DTO) that mirrors the JSON fields for a single feed entry.
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
}
