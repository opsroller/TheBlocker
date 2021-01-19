//
//  CRUDRepositoryAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData

enum CRUDRepositoryAction<Item: UnmanagedModel>: Hashable, Equatable {
    typealias Success = Repository.CRUD.Success<Item>
    typealias Failure = Repository.CRUD.Failure<Item>
    case create(Item)
    case read(NSManagedObjectID, Item.ID)
    case update(Item, NSManagedObjectID)
    case delete(NSManagedObjectID, Item.ID)
    case repoResult(Result<Success, Failure>)
}
