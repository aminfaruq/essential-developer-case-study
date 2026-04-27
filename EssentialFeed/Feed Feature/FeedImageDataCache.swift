//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Amin faruq on 08/04/26.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
