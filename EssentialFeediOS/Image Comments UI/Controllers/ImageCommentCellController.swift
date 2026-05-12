//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 12/05/26.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        cell.messageLabel.text = model.message
        return cell
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }
    
    public func registerIfNeeded(in tableView: UITableView) {
        tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageCommentCell")
    }
}
