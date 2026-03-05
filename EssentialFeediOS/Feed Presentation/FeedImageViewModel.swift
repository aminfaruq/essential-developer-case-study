//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Amin faruq on 03/03/26.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool { location != nil }
}
