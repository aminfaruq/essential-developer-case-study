//
//  ImageCommentCell.swift
//  EssentialFeed
//
//  Created by Amin faruq on 12/05/26.
//

import UIKit
internal import SnapKit

public final class ImageCommentCell: UITableViewCell {
    public let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .equalSpacing
        return stack
    }()
    
    public let messageLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    public let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    public let dateLabel:  UILabel = {
        let label = UILabel()
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(dateLabel)
      
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(22)
        }
        contentView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottomMargin).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
