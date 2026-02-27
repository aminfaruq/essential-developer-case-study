//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Amin faruq on 28/02/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
