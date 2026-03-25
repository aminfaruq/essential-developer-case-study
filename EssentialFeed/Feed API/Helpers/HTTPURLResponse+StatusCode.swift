//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Amin faruq on 25/03/26.
//

import Foundation

extension HTTPURLResponse {
    /// Only HTTP 200 responses are considered valid for mapping.
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
