//
//  FeedLoaderWithFallbackCompositeTests.swift
//  FeedLoaderWithFallbackCompositeTests
//
//  Created by Amin faruq on 31/03/26.
//

import XCTest
import EssentialFeed
import EssentialApp

@MainActor
final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
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
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = await MainActor.run {
            FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        }
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        return sut
    }
    
    func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }
    
    private func uniqueFeed() -> [FeedImage] {
        [
            FeedImage(
                id: UUID(),
                description: "any",
                location: "any",
                url: URL(string: "http://any-url.com")!
            )
        ]
    }
    
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instead should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    @MainActor
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
}
