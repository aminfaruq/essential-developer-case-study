//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 22/12/25.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
