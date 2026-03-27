//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Amin faruq on 11/02/26.
//

import CoreData

public final class CoreDataFeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = Bundle(for: CoreDataFeedStore.self)) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        
        context = container.newBackgroundContext()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
