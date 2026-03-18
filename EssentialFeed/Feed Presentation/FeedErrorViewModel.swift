//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Amin faruq on 14/03/26.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
