//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Amin faruq on 28/02/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
