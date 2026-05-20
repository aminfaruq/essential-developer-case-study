//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Amin faruq on 28/02/26.
//

import UIKit

public extension UIControl {
    /// Simulates sending a UIControl.Event to this control, invoking any registered targets/actions.
    /// Must be called on the main thread.
    func simulate(event: UIControl.Event) {
        for target in allTargets {
            guard let object = target as AnyObject? else { continue }
            actions(forTarget: object, forControlEvent: event)?.forEach { action in
                UIApplication.shared.sendAction(Selector(action), to: object, from: self, for: nil)
            }
        }
    }
}
