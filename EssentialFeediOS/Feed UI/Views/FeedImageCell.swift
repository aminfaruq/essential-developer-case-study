//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by Amin faruq on 25/02/26.
//

import UIKit
internal import SnapKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIStackView()
    public let locationLabel = UILabel()
    public let pinImageView: UIImageView = {
        let bundle = Bundle(for: FeedImageCell.self)
        let image = UIImage(named: "pin", in: bundle, compatibleWith: nil)
        return UIImageView(image: image)
    }()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↻", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // MARK: - Setup location container -
        locationContainer.axis = .horizontal
        locationContainer.alignment = .top
        locationContainer.spacing = 6
        contentView.addSubview(locationContainer)
        
        locationContainer.addArrangedSubview(pinImageView)
        locationContainer.addArrangedSubview(locationLabel)
        
        pinImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 10, height: 14)) // Pin image size
        }
        
        locationLabel.numberOfLines = 2
        locationLabel.font = UIFont.systemFont(ofSize: 15)
        locationLabel.textColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
        
        // MARK: - Setup feed image container -
        feedImageContainer.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
        feedImageContainer.layer.cornerRadius = 22
        contentView.addSubview(feedImageContainer)
        
        feedImageContainer.addSubview(feedImageView)
        feedImageContainer.addSubview(feedImageRetryButton)
        
        feedImageView.contentMode = .scaleAspectFit
        
        // MARK: - Setup description label -
        descriptionLabel.numberOfLines = 6
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = UIColor(red: 0.64, green: 0.64, blue: 0.64, alpha: 1.0)
        contentView.addSubview(descriptionLabel)
        
        // MARK: - Setup constraints using SnapKit -
        locationContainer.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.topMargin).offset(6)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailingMargin)
        }
        
        feedImageContainer.snp.makeConstraints { make in
            make.top.equalTo(locationContainer.snp.bottom).offset(10)
            make.leading.equalTo(locationContainer.snp.leading)
            make.trailing.equalTo(locationContainer.snp.trailing)
            make.height.equalTo(feedImageContainer.snp.width) // Maintain a square aspect ratio
        }
        
        feedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        feedImageRetryButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(feedImageContainer.snp.bottom).offset(10)
            make.leading.equalTo(feedImageContainer.snp.leading)
            make.trailing.equalTo(feedImageContainer.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottomMargin).offset(-10)
        }
    }
}
