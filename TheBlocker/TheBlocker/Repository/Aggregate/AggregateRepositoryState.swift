//
//  AggregateRepositoryState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

struct AggregateRepositoryState<Model: UnmanagedModel>: Equatable {
    var count: Int = 0
    var isWorking: Bool = false
    var fetchID: AnyHashable

    func fetchRequest(predicate: NSPredicate) -> FetchRequest<Model> {
        FetchRequest<Model>(id: fetchID, predicate: predicate)
    }
}
