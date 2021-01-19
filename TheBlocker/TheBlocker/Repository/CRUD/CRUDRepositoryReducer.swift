//
//  CRUDRepositoryReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import ComposableArchitecture

extension Reducer {
    static func crudRepository<Model: UnmanagedModel>() -> Reducer<
        CRUDRepositoryState,
        CRUDRepositoryAction<Model>,
        CRUDRepositoryEnv<Model>
    > {
        // swiftlint:disable:next nesting
        typealias Action = CRUDRepositoryAction<Model>
        return Reducer<CRUDRepositoryState, Action, CRUDRepositoryEnv<Model>> { _, action, env in
            switch action {
            case .create(let item):
                return env.repo.create(item)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(Action.repoResult)
                    .cancellable(id: action)
            case let .read(objectID, id):
                return env.repo.read(objectID, id)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(Action.repoResult)
                    .cancellable(id: action)
            case let .update(item, objectID):
                return env.repo.update(item, objectID)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(Action.repoResult)
                    .cancellable(id: action)
            case let .delete(objectID, id):
                return env.repo.delete(objectID, id)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(Action.repoResult)
                    .cancellable(id: action)
            default:
                return .none
            }
        }
    }
}
