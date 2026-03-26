//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Amin faruq on 26/03/26.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
