//
//  LoadResourcePresentationAdapter<Resource, View: ResourceView>.swift
//  EssentialFeed
//
//  Created by Amin faruq on 10/03/26.
//
import Combine
import EssentialFeed
import EssentialFeediOS

public final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
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
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    //var presenter: FeedPresenter?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    //init(feedLoader: @escaping () -> FeedLoader.Publisher) {
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    public func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
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
                receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                }
            )
    }
}

//extension LoadResourcePresentationAdapter: FeedRefreshViewControllerDelegate {
//    func didRequestFeedRefresh() {
//        loadResource()
//    }
//}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    public func didRequestImage() {
        loadResource()
    }
    
    public func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
