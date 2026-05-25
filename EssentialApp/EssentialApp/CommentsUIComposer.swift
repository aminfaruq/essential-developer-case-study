//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Amin faruq on 23/05/26.
//
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
        
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
        
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        let refreshController = FeedRefreshViewController()
        refreshController.onRefresh = presentationAdapter.loadResource
        
        let commentsController = makeCommentsViewController(
            refreshDelegate: refreshController,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentsController),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) })
        
        return commentsController
    }
    
    private static func makeCommentsViewController(refreshDelegate: FeedRefreshViewController, title: String) -> ListViewController{
        let feedController = ListViewController(refreshController: refreshDelegate)
        feedController.title = ImageCommentsPresenter.title
        return feedController
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map({ viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        }))
    }
}
