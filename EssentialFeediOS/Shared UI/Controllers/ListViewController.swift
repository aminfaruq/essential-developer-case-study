//
//  ListViewController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 21/02/26.
//

import UIKit
import EssentialFeed

public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching & RegisterController

public protocol RegisterController {
    func registerIfNeeded(in tableView: UITableView)
}

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceErrorView {
    private var refreshController: FeedRefreshViewController?
    public let errorView = ErrorView()
    
    private var loadingControllers = [IndexPath: CellController]()
    
    private var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    private func registerTableView() {
        tableView.tableHeaderView = errorView
        tableView.sizeTableHeaderToFit()
        tableView.prefetchDataSource = self
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        refreshControl = refreshController?.view
        refreshController?.refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
        cellControllers.forEach { $0.registerIfNeeded(in: tableView) }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
        tableView.sizeTableHeaderToFit()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingController(forRowAt: indexPath)
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
    
    @objc private func hideErrorView() {
        tableView.beginUpdates()
        tableView.tableHeaderView = nil
        tableView.endUpdates()
    }
}
