//
//  FeedEndpointTests.swift
//  EssentialFeed
//
//  Created by Amin faruq on 25/05/26.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        
        let expected = URL(string: "http://base-url.com/v1/feed")!
        
        XCTAssertEqual(received, expected)
    }
}
