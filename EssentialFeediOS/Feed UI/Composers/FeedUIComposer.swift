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
        
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)), loadingView: WeakRefVirtualProxy(refreshController)
        )
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedRefreshViewControllerDelegate, refreshDelegate: FeedRefreshViewController, title: String) -> FeedViewController {
        let feedController = FeedViewController(refreshController: refreshDelegate)
        feedController.title = FeedPresenter.title
        return feedController
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map({ model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            
            return view
        })
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
