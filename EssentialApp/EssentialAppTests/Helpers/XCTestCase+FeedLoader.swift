//
//  XCTestCase+FeedLoader.swift
//  EssentialApp
//
//  Created by Amin faruq on 07/04/26.
//

#warning("Unnecessary because use combine way")
//import XCTest
//import EssentialFeed
//
//protocol FeedLoaderTestCase: XCTestCase {}
//
//extension FeedLoaderTestCase {
//    
//    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
//        let exp = expectation(description: "Wait for load completetion")
//        
//        sut.load { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedFeed), .success(expectedFeed)):
//                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
//                
//            case (.failure, .failure):
//                break
//                
//            default:
//                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
//            }
//            
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0)
//    }
//}
