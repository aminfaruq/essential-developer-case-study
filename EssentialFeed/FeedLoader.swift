//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 22/12/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
