//
//  ListViewController.swift
//  EssentialFeed
//
//  Created by Amin faruq on 21/02/26.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceErrorView {
    private var refreshController: FeedRefreshViewController?
    private(set) public var errorView = ErrorView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, index, controller) -> UITableViewCell? in
            let ds = controller.dataSource
            return ds.tableView(tableView, cellForRowAt: index)
        }
    }()
    
    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        refreshControl = refreshController?.view
        refreshController?.refresh()
    }
    
    private func configureTableView() {
        tableView.prefetchDataSource = self
        tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 580
        tableView.tableHeaderView = errorView.makeContainer()
        dataSource.defaultRowAnimation = .fade

        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellControllers: [CellController]) {
        //loadingControllers = [:]
        //tableModel = cellControllers
        cellControllers.forEach { $0.registerIfNeeded(in: tableView) }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    //public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //tableModel.count
    //}
    
    //public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let ds = cellController(forRowAt: indexPath).dataSource
    //return ds.tableView(tableView, cellForRowAt: indexPath)
    //}
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    //private func cellController(forRowAt indexPath: IndexPath) -> CellController {
    //let controller = tableModel[indexPath.row]
    //loadingControllers[indexPath] = controller
    //return controller
    //}
    
    //private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
    //let controller = loadingControllers[indexPath]
    //loadingControllers[indexPath] = nil
    //return controller
    //}
}
