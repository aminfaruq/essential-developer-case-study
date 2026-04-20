//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Amin faruq on 07/04/26.
//
import Combine
import EssentialFeed

//MARK: - Combine way

extension Publisher where Output == [FeedImage] {
    /*func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        map { feed in
            cache.saveIgnoringResult(feed)
            return feed
        }
        .eraseToAnyPublisher()
    }*/
    
    // Other way to use combine
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map({ feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            }))
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed, completion: { _ in })
    }
}
