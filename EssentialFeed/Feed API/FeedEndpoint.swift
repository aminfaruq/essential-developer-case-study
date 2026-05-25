//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Amin faruq on 25/05/26.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
