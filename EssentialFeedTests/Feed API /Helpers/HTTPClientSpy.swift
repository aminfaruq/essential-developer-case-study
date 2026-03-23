//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Amin faruq on 23/03/26.
//

import Foundation
import EssentialFeed

/// Test double for `HTTPClient`.
/// Stores incoming requests and provides APIs to complete them
/// with success or failure in a controlled way during tests.
class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        
        func cancel() { callback() }
    }
    
    // Stores the (URL, completion) pair for each performed request.
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    // List of requested URLs (order matters for verification).
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    // Records the request without performing real network calls.
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            
            self?.cancelledURLs.append(url)
        }
    }
    
    // Simulates completing the request with an error at a given index (default: 0).
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    // Simulates completing the request successfully with a status code and data at a given index (default: 0).
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        
        messages[index].completion(.success((data, response)))
    }
}
