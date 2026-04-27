//
//  URLProtocolStub.swift
//  EssentialFeed
//
//  Created by Amin faruq on 25/03/26.
//
import Foundation

/// `URLProtocol` stub to intercept network requests.
/// Allows observing requests and/or injecting data/response/error without real networking.
class URLProtocolStub: URLProtocol {
    
    // Container for possible stub values: data, response, and/or error.
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    // Holds the stubbed values returned when a request is intercepted.
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        
        set { queue.sync { _stub = newValue } }
    }
    
    private static let queue = DispatchQueue(label: "URLProtocol.queue")
    
    /// Sets the global stub values to be used when a request is intercepted.
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    /// Registers an observer to receive each incoming `URLRequest`.
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    /// Stops intercepting and clears the stub/observer state.
    static func removeStub() {
        stub = nil
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
        
        stub.requestObserver?(request)
    }
    
    /// Nothing special to do on stop; required to fulfill the `URLProtocol` contract.
    override func stopLoading() {}
}
