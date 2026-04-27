//
//  FeedLoaderWithFallbackCompositeTests.swift
//  FeedLoaderWithFallbackCompositeTests
//
//  Created by Amin faruq on 31/03/26.
//
#warning("Unnecessary because use combine way")
/*
import XCTest
import EssentialFeed
import EssentialApp

@MainActor
final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() async {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = await makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() async {
        let fallbackFeed = uniqueFeed()
        let sut = await makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() async {
        let sut = await makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) async -> FeedLoader {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = await MainActor.run {
            FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        }
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        return sut
    }
}
*/
