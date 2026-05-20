//
//  UIView+Container.swift
//  EssentialFeed
//
//  Created by Amin faruq on 20/05/26.
//

import UIKit
internal import SnapKit

extension UIView {
    
    public func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return container
    }
    
}
