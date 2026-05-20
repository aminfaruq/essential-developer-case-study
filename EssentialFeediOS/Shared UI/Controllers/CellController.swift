//
//  CellController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 13/05/26.
//
import UIKit

public protocol RegisterController{
    func registerIfNeeded(in tableView: UITableView)
}

public struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    let registerController: RegisterController?
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching & RegisterController) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
        self.registerController = dataSource
    }
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource & RegisterController) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
        self.registerController = dataSource
    }
    
    public func registerIfNeeded(in tableView: UITableView) {
        registerController?.registerIfNeeded(in: tableView)
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
