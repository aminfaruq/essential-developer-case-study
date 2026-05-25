//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Amin faruq on 06/04/26.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

func anyData() -> Data { Data("any data".utf8) }

func anyURL() -> URL { URL(string: "http://a-url.com")! }

func uniqueFeed() -> [FeedImage] {
    [
        FeedImage(
            id: UUID(),
            description: "any",
            location: "any",
            url: anyURL()
        )
    ]
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
