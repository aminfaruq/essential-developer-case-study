//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Amin faruq on 03/02/26.
//

import Foundation

func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

func anyURL() -> URL { URL(string: "http://any-url.com")! }

/// Arbitrary data for testing purposes.
func anyData() -> Data { Data(_: "any data".utf8) }

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
