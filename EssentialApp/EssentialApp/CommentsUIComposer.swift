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
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
        let refreshController = FeedRefreshViewController()
        refreshController.onRefresh = presentationAdapter.loadResource
        let feedController = makeViewController(
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }
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
