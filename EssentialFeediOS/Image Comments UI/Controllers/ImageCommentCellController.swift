//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 12/05/26.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, UITableViewDataSource, RegisterController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        cell.messageLabel.text = model.message
        return cell
    }
    
    public func registerIfNeeded(in tableView: UITableView) {
        tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageCommentCell")
    }
}
