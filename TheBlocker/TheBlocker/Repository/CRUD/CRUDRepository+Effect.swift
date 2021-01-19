//
//  CRUDRepository+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import ComposableArchitecture

extension Repository.CRUD {
    func create<Model: UnmanagedModel>(_ item: Model) -> Effect<Success<Model>, Failure<Model>> {
        Effect.future { [weak self] callback in
            guard let self = self else { return callback(.failure(.create(item.id, .unknown))) }
            let result: Result<Success<Model>, Failure<Model>> = self.create(item)
            callback(result)
        }
    }

    func read<Model: UnmanagedModel>(
        _ objectID: NSManagedObjectID,
        id: Model.ID
    ) -> Effect<Success<Model>, Failure<Model>> {
        Effect.future { [weak self] callback in
            guard let self = self else { return callback(.failure(.read(id, .unknown))) }
            let result: Result<Success<Model>, Failure<Model>> = self.read(objectID, id: id)
            callback(result)
        }
    }

    func update<Model: UnmanagedModel>(
        _ item: Model,
        objectID: NSManagedObjectID
    ) -> Effect<Success<Model>, Failure<Model>> {
        Effect.future { [weak self] callback in
            guard let self = self else { return callback(.failure(.update(item.id, .unknown))) }
            let result: Result<Success<Model>, Failure<Model>> = self.update(item, objectID: objectID)
            callback(result)
        }
    }

    func delete<Model: UnmanagedModel>(
        _ objectID: NSManagedObjectID,
        id: Model.ID
    ) -> Effect<Success<Model>, Failure<Model>> {
        Effect.future { [weak self] callback in
            guard let self = self else { return callback(.failure(.delete(id, .unknown))) }
            let result: Result<Success<Model>, Failure<Model>> = self.delete(objectID, id: id)
            callback(result)
        }
    }
}
