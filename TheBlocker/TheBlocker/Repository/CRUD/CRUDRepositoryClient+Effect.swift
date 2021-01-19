//
//  CRUDRepositoryClient+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import ComposableArchitecture

struct CRUDRepositoryClientEffect<Item: UnmanagedModel> {
    typealias Success = Repository.CRUD.Success<Item>
    typealias Failure = Repository.CRUD.Failure<Item>
    let create: (Item) -> Effect<Success, Failure>
    let read: (NSManagedObjectID, Item.ID) -> Effect<Success, Failure>
    let update: (Item, NSManagedObjectID) -> Effect<Success, Failure>
    let delete: (NSManagedObjectID, Item.ID) -> Effect<Success, Failure>
}

extension CRUDRepositoryClientEffect {
    static func prod(_ repo: Repository.CRUD) -> Self {
        Self(create: repo.create, read: repo.read, update: repo.update, delete: repo.delete)
    }
}

extension CRUDRepositoryClientEffect {
    static func mock(
        create: @escaping (Item) -> Effect<Success, Failure> = { _ in fatalError() },
        read: @escaping (NSManagedObjectID, Item.ID) -> Effect<Success, Failure> = { _, _ in fatalError() },
        update: @escaping (Item, NSManagedObjectID) -> Effect<Success, Failure> = { _, _ in fatalError() },
        delete: @escaping (NSManagedObjectID, Item.ID) -> Effect<Success, Failure> = { _, _ in fatalError() }
    ) -> Self {
        Self(create: create, read: read, update: update, delete: delete)
    }
}
