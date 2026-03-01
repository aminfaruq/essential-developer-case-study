//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//
import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
