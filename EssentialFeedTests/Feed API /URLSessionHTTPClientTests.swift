//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Amin faruq on 06/01/26.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    // A collection of unit tests for `URLSessionHTTPClient`.
    // Goal: Ensure the client performs a correct GET request and maps data/response/error
    // combinations into the appropriate result (success/failure).
    // Strategy: Use `URLProtocolStub` to intercept network requests and inject
    // stubbed data/response/error, as well as observe the outgoing requests.
    
    // Stop intercepting and clean up the stub/observer so other tests aren't affected.
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
    }
    
    // Verifies that `get(from:)` performs a GET request to the given URL.
    func test_getFromUrl_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    // If a request-level error occurs (e.g., connection fails), the client should return the same error.
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    // Invalid combinations of (data/response/error) should result in failure.
    // This ensures only the combination of data + HTTPURLResponse (with no error) is treated as success.
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    // When receiving a valid `HTTPURLResponse` with data, it should succeed and return the (data, response) pair.
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // When receiving a valid `HTTPURLResponse` with nil data, it should succeed with empty `Data()` instead.
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    
    // MARK: - Helpers
    
    /// Creates a `URLSessionHTTPClient` instance as the SUT and enables memory leak tracking.
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    /// Helper to extract success values (data, response); fails if the result isn't success.
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        
        switch result {
        case .success((let data, let response)):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    /// Helper to extract the error from the result; fails if the result isn't failure.
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error as NSError
            
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    /// Central helper: set the stub (data/response/error), create the SUT, perform the request, and wait for the result.
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?,  taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map({
            URLProtocolStub.stub(data: $0, response: $1, error: $2)
        })
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL(), completion: { result in
            receivedResult = result
            
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    /// Non-HTTP `URLResponse` (no status code) for invalid cases.
    private func nonHTTPURLResponse() -> URLResponse { URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    
    /// Valid `HTTPURLResponse` (default status code 200) for valid cases.
    private func anyHTTPURLResponse() -> HTTPURLResponse { HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
}

