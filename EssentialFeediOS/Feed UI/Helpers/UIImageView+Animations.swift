//
//  UIImageView+Animations.swift
//  EssentialFeed
//
//  Created by Amin faruq on 07/05/26.
//

import UIKit

extension UIImageView {
    
    func setImageAnimated(_ newImage: UIImage?) {
            guard let newImage = newImage else {
                self.image = nil
                return
            }
            
            UIView.transition(
                with: self,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: {
                    self.image = newImage
                },
                completion: nil
            )
        }
}
