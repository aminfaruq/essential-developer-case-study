//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject, ResourceLoadingView {
    
    private(set) lazy var view: UIRefreshControl = loadView()

    public var onRefresh: (() -> Void)?
    
    @objc func refresh() {
        onRefresh?()
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
