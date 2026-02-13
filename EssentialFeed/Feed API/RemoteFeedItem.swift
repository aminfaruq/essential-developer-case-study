//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/02/26.
//

import Foundation

/// Data Transfer Object (DTO) that mirrors the JSON fields for a single feed entry.
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
