//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amin faruq on 23/12/25.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    // Unit tests for `RemoteFeedLoader`.
    // Goal: Ensure the interaction with `HTTPClient` and the delivered results (success/failure)
    // match different HTTP response and data conditions.
    // Strategy: Use `HTTPClientSpy` as a test double to record requests and
    // simulate completions (success/failure) without real networking.
    // MARK: - Tests
    
    // Initializing `RemoteFeedLoader` must not request data from the URL.
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // Calling `load()` should request data from the given URL.
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // Calling `load()` twice should issue two requests to the same URL.
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // If `HTTPClient` completes with an error, `load()` should deliver `.failure(.connectivity)`.
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    // For any status code other than 200, `load()` should deliver `.failure(.invalidData)`.
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // For a 200 response with invalid JSON payload, `load()` should deliver `.failure(.invalidData)`.
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data(_: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    // For a 200 response with an empty items list, `load()` should deliver `.success([])`.
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    // For a 200 response with valid JSON, `load()` should map the payload into an array of `FeedImage`.
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
                
        expect(sut, toCompleteWith: .success(items), when: {
            
            let json = makeItemsJSON([item1.json, item2.json])
            
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // If the SUT instance has been deallocated, it must not deliver the completion.
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load(completion: {  capturedResults.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    /// Creates a SUT (`RemoteFeedLoader`) and its `HTTPClientSpy`.
    /// - Parameters:
    ///   - url: The URL to be used by the SUT.
    ///   - file: File info for memory leak tracking.
    ///   - line: Line info for memory leak tracking.
    /// - Returns: A tuple of the SUT and the spy client with leak tracking applied.
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    /// Helper to express failure expectations more succinctly.
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    /// Creates a `FeedImage` and its equivalent JSON representation.
    /// Nil `description`/`location` values are removed from the JSON using `compactMapValues(_:)`.
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues({ $0 })
        
        return (item, json)
    }
    
    /// Wraps the array of item dictionaries in the `{ "items": [...] }` envelope and serializes to `Data`.
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    /// General helper to perform load, wait for completion, and assert against the expected result.
    /// - Parameters:
    ///   - sut: The system under test.
    ///   - expectedResult: The expected outcome (success/failure).
    ///   - when: The action that triggers request completion on `HTTPClientSpy`.
    ///   - file: Auto-filled for accurate failure reporting.
    ///   - line: Auto-filled for accurate failure reporting.
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                
                XCTAssertEqual(receivedError as RemoteFeedLoader.Error, expectedError , file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    /// Test double for `HTTPClient`.
    /// Stores incoming requests and provides APIs to complete them
    /// with success or failure in a controlled way during tests.
    private class HTTPClientSpy: HTTPClient {
        
        // Stores the (URL, completion) pair for each performed request.
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        // List of requested URLs (order matters for verification).
        var requestedURLs: [URL] {
            return messages.map({ $0.url })
        }
        
        // Records the request without performing real network calls.
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
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
                headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}

