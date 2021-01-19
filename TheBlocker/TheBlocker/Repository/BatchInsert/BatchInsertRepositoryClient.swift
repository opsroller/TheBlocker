//
//  BatchInsertRepositoryClient.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import Combine

struct BatchInsertRepositoryClient {
    let insert: ([[String: Any]], String) ->
        AnyPublisher<Repository.BatchInsert.Success, Repository.BatchInsert.Failure>
}

extension BatchInsertRepositoryClient {
    static func prod(context: NSManagedObjectContext) -> Self {
        let repo = Repository.BatchInsert(context: context)
        return Self(insert: repo.insert)
    }
}
