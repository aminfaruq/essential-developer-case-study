//
//  UIButton+TestsHelpers.swift
//  EssentialFeed
//
//  Created by Amin faruq on 28/02/26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}
