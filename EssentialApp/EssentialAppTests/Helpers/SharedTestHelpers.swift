//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Amin faruq on 06/04/26.
//

import Foundation

func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

func anyData() -> Data { Data("any data".utf8) }

func anyURL() -> URL { URL(string: "http://a-url.com")! }

