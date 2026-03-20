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
    
    // Start intercepting all network requests via `URLProtocolStub`.
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    // Stop intercepting and clean up the stub/observer so other tests aren't affected.
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
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
        let sut = URLSessionHTTPClient()
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
    
    /// Arbitrary data for testing purposes.
    private func anyData() -> Data { Data(_: "any data".utf8) }
    
    /// Non-HTTP `URLResponse` (no status code) for invalid cases.
    private func nonHTTPURLResponse() ->  URLResponse { URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    
    /// Valid `HTTPURLResponse` (default status code 200) for valid cases.
    private func anyHTTPURLResponse() -> HTTPURLResponse { HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    
    
    /// `URLProtocol` stub to intercept network requests.
    /// Allows observing requests and/or injecting data/response/error without real networking.
    private class URLProtocolStub: URLProtocol {
        
        // Holds the stubbed values returned when a request is intercepted.
        private static var stub: Stub?
        // Optional callback to observe each incoming request (e.g., verify URL/method).
        private static var requestObserver: ((URLRequest) -> Void)?
        
        // Container for possible stub values: data, response, and/or error.
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        /// Sets the global stub values to be used when a request is intercepted.
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        /// Registers an observer to receive each incoming `URLRequest`.
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        /// Starts intercepting all requests by registering the `URLProtocolStub` class.
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        /// Stops intercepting and clears the stub/observer state.
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            
            stub = nil
            requestObserver = nil
        }
        
        /// Intercept all requests (return `true` so the URLLoadingSystem uses this stub).
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        /// Return the request as-is (no normalization needed).
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            // If there's an observer, notify it with the request and finish loading.
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            // If there's stubbed data, send it to the client.
            
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            // If there's a stubbed response, send it to the client.
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            // If there's a stubbed error, report the failure to the client.
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                // Signal that loading has finished.
                client?.urlProtocolDidFinishLoading(self)
            }
            
        }
        
        /// Nothing special to do on stop; required to fulfill the `URLProtocol` contract.
        override func stopLoading() {}
    }
}

