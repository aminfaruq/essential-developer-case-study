//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Amin faruq on 11/03/26.
//

import UIKit
internal import SnapKit

public final class ErrorView: UIView {
        
    public var message: String? {
        get { return isVisible ? messageLabel.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemRed
        addSubview(messageLabel)
        setupConstraints()
        alpha = 0
        messageLabel.text = nil
        messageLabel.numberOfLines = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideMessageAnimated))
        addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        messageLabel.text = message
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { [weak self] completed in
                if completed {
                    self?.messageLabel.text = nil
                }
            }
        )
    }
}
