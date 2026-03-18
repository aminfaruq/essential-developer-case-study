//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        
        let feedController = makeViewController(
            delegate: presentationAdapter,
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(feedController)
        )
        
        return feedController
    }
    
    private static func makeViewController(delegate: FeedRefreshViewControllerDelegate, refreshDelegate: FeedRefreshViewController, title: String) -> FeedViewController{
        let feedController = FeedViewController(refreshController: refreshDelegate)
        feedController.title = FeedPresenter.title
        return feedController
    }
}
