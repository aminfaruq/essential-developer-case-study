//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Amin faruq on 22/12/25.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL 
}
