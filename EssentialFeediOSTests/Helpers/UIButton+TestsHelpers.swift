//
//  UIButton+TestsHelpers.swift
//  EssentialFeed
//
//  Created by Amin faruq on 28/02/26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
