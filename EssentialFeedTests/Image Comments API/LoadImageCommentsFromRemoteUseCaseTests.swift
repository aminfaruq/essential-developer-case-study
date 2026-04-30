//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeed
//
//  Created by Amin faruq on 29/04/26.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
        
    // For any status code other than 200, `load()` should deliver `.failure(.invalidData)`.
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // For a 200 response with invalid JSON payload, `load()` should deliver `.failure(.invalidData)`.
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data(_: "invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
       
    }
    
    // For a 200 response with an empty items list, `load()` should deliver `.success([])`.
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }
    
    // For a 200 response with valid JSON, `load()` should map the payload into an array of `FeedImage`.
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items), when: {
                
                let json = makeItemsJSON([item1.json, item2.json])
                
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // MARK: Helpers
    
    /// Creates a SUT (`RemoteImageCommentsLoader`) and its `HTTPClientSpy`.
    /// - Parameters:
    ///   - url: The URL to be used by the SUT.
    ///   - file: File info for memory leak tracking.
    ///   - line: Line info for memory leak tracking.
    /// - Returns: A tuple of the SUT and the spy client with leak tracking applied.
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    /// Helper to express failure expectations more succinctly.
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    /// Creates a `FeedImage` and its equivalent JSON representation.
    /// Nil `description`/`location` values are removed from the JSON using `compactMapValues(_:)`.
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iSO8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iSO8601String,
            "author": [
                "username" : username
            ]
        ]
        
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
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                
                XCTAssertEqual(receivedError as RemoteImageCommentsLoader.Error, expectedError , file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
