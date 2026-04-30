//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Amin faruq on 29/04/26.
//

import XCTest
import EssentialFeed

final class RemoteLoaderTests: XCTestCase {
    
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
    
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            
            throw anyNSError()
        })
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: anyData())
        })
    }
    
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toCompleteWith: .success(resource), when: {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        })
    }
    
    // If the SUT instance has been deallocated, it must not deliver the completion.
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "any" })
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load(completion: {  capturedResults.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    /// Creates a SUT (`RemoteLoader`) and its `HTTPClientSpy`.
    /// - Parameters:
    ///   - url: The URL to be used by the SUT.
    ///   - file: File info for memory leak tracking.
    ///   - line: Line info for memory leak tracking.
    /// - Returns: A tuple of the SUT and the spy client with leak tracking applied.
    private func makeSUT(
        url: URL = URL(string: "https://a-given-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    /// Helper to express failure expectations more succinctly.
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
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
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                
                XCTAssertEqual(receivedError as RemoteLoader.Error, expectedError , file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
