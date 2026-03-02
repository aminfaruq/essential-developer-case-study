//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 02/03/26.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private var feedloader: FeedLoader
    
    init(feedloader: FeedLoader) {
        self.feedloader = feedloader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedloader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        })
    }
}
