//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Amin faruq on 23/05/26.
//
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
        
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
        
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController()
        refreshController.onRefresh = presentationAdapter.loadResource
        let feedController = makeViewController(
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader
            ),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeViewController(refreshDelegate: FeedRefreshViewController, title: String) -> ListViewController{
        let feedController = ListViewController(refreshController: refreshDelegate)
        feedController.title = ImageCommentsPresenter.title
        return feedController
    }
}
