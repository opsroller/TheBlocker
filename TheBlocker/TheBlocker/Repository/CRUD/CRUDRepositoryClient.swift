//
//  CRUDRepositoryClient.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData

struct CRUDRepositoryClient<Model: UnmanagedModel> {
    typealias Success = Repository.CRUD.Success<Model>
    typealias Failure = Repository.CRUD.Failure<Model>
    let create: (Model) -> Result<Success, Failure>
    let read: (NSManagedObjectID, Model.ID) -> Result<Success, Failure>
    let update: (Model, NSManagedObjectID) -> Result<Success, Failure>
    let delete: (NSManagedObjectID, Model.ID) -> Result<Success, Failure>
}

extension CRUDRepositoryClient {
    static func prod(_ repo: Repository.CRUD) -> Self {
        Self(create: repo.create, read: repo.read, update: repo.update, delete: repo.delete)
    }
}

extension CRUDRepositoryClient {
    static func mock(
        create: @escaping (Model) -> Result<Success, Failure> = { _ in fatalError() },
        read: @escaping (NSManagedObjectID, Model.ID) -> Result<Success, Failure> = { _, _ in fatalError() },
        update: @escaping (Model, NSManagedObjectID) -> Result<Success, Failure> = { _, _ in fatalError() },
        delete: @escaping (NSManagedObjectID, Model.ID) -> Result<Success, Failure> = { _, _ in fatalError() }
    ) -> Self {
        Self(create: create, read: read, update: update, delete: delete)
    }
}
