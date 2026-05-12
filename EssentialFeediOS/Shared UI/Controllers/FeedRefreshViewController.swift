//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//

import UIKit
import EssentialFeed

//public protocol FeedRefreshViewControllerDelegate {
//    func loadResource()
//}

public final class FeedRefreshViewController: NSObject, ResourceLoadingView {
    
    private(set) lazy var view: UIRefreshControl = loadView()
    
    //    private let delegate: FeedRefreshViewControllerDelegate
    
    //    public init(delegate: FeedRefreshViewControllerDelegate) {
    //        self.delegate = delegate
    //    }
    
    public var onRefresh: (() -> Void)?
    
    @objc func refresh() {
        onRefresh?()
        //        delegate.loadResource()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
