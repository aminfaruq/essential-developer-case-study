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

extension Date {
    func adding(seconds: TimeInterval) -> Date { self + seconds }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
