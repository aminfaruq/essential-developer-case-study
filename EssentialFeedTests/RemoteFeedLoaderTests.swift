//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Amin faruq on 23/12/25.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL? 
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        
        XCTAssertNil(client.requestedURL)
    }
}
