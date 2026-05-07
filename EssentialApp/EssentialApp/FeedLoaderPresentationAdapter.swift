//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Amin faruq on 10/03/26.
//
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    /*
     private let feedLoader: FeedLoader
     var presenter: FeedPresenter?
     
     init(feedLoader: FeedLoader) {
     self.feedLoader = feedLoader
     }
     
     public func didRequestFeedRefresh() {
     presenter?.didStartLoadingFeed()
     
     feedLoader.load { [weak self] result in
     switch result {
     case let .success(feed):
     self?.presenter?.didFinishLoadingFeed(with: feed)
     case let .failure(error):
     self?.presenter?.didFinishLoadingFeed(with: error)
     }
     }
     }*/
    
    //MARK: - Combine Way
    //private let feedLoader: () -> FeedLoader.Publisher
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    //var presenter: FeedPresenter?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    //init(feedLoader: @escaping () -> FeedLoader.Publisher) {
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    public func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                    
                },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                }
            )
    }
}
