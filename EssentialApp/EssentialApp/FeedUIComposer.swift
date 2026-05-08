//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() {}
    
    /*public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
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
     }*/
    
    //MARK: - Side effect use combine
//    public static func feedComposedWith(
//        feedLoader: @escaping () -> FeedLoader.Publisher,
//        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
//    ) -> FeedViewController {
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
        
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        
        //let presentationAdapter = LoadResourcePresentationAdapter<Resource, View: ResourceView>(feedLoader: { feedLoader() })
        
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        
        let feedController = makeViewController(
            delegate: presentationAdapter,
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        //        presentationAdapter.presenter = FeedPresenter(
        //            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
        //            loadingView: WeakRefVirtualProxy(refreshController),
        //            errorView: WeakRefVirtualProxy(feedController)
        //        )
        
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
    
    private static func makeViewController(delegate: FeedRefreshViewControllerDelegate, refreshDelegate: FeedRefreshViewController, title: String) -> FeedViewController{
        let feedController = FeedViewController(refreshController: refreshDelegate)
        feedController.title = FeedPresenter.title
        return feedController
    }
}
