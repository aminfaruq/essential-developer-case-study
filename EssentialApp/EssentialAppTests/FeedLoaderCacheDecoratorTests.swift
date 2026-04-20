//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialApp
//
//  Created by Amin faruq on 07/04/26.
//
#warning("Unnecessary because use combine way")

import XCTest
import EssentialApp
import EssentialFeed

@MainActor
final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() async {
        let feed = uniqueFeed()
        let sut = await makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() async {
        let sut = await makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() async {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = await makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() async {
        let cache = CacheSpy()
        let sut = await makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        
        sut.load(completion: { _ in })
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not cache feed on load error")
    }
    
    // MARK: - Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(),file: StaticString = #filePath, line: UInt = #line) async -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = await MainActor.run {
            FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        }
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
