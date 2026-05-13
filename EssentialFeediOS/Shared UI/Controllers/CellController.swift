//
//  CellController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 13/05/26.
//
import UIKit

public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    let registerController: RegisterController?
    
    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching & RegisterController) {
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
        self.registerController = dataSource
    }
    
    public init(_ dataSource: UITableViewDataSource & RegisterController) {
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
        self.registerController = dataSource
    }
    
    public func registerIfNeeded(in tableView: UITableView) {
        registerController?.registerIfNeeded(in: tableView)
    }
}
