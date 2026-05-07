//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Amin faruq on 14/03/26.
//
import Foundation

//public protocol FeedView {
//    func display(_ viewModel: FeedViewModel)
//}

public protocol FeedLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

//public protocol FeedErrorView {
//    func display(_ viewModel: FeedErrorViewModel)
//}

public final class FeedPresenter {
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
