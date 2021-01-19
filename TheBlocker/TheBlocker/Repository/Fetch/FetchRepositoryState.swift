//
//  FetchRepositoryState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

struct FetchRepositoryState<Model: UnmanagedModel>: Equatable {
    var items: [Model] = []
    var isFetching: Bool = false
    var fetchLimit: Int = 100
    var fetchPageSize: Int = 100
    var fetchID: AnyHashable
    var fetchCount: Int = 0
    // Cache the most recent predicate and sort desc for fetchMore
    var recentPredicate: NSPredicate = NSPredicate(value: true)
    var recentSortDesc: [NSSortDescriptor] = []

    func fetchRequest(predicate: NSPredicate, sortDesc: [NSSortDescriptor]) -> FetchRequest<Model> {
        FetchRequest<Model>(id: fetchID, offset: 0, limit: fetchLimit, predicate: predicate, sortDesc: sortDesc)
    }
}
