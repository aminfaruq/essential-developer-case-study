//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Amin faruq on 09/02/26.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
