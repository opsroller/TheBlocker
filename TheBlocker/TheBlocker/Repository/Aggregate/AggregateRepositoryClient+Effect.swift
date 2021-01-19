//
//  AggregateRepositoryClient+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import CoreData
import Combine
import ComposableArchitecture

struct AggregateRepositoryClientEffect<Model: UnmanagedModel> {
    typealias Success = Repository.Aggregate.Success
    typealias Failure = Repository.Aggregate.Failure<Model>
    let count: (FetchRequest<Model>) -> Effect<Success, Failure>
}

extension AggregateRepositoryClientEffect {
    static func prod(_ repo: Repository.Aggregate) -> Self {
        Self(count: repo.count)
    }
}

extension AggregateRepositoryClientEffect {
    static func mock(
        count: @escaping (FetchRequest<Model>) -> Effect<Success, Failure> = { _ in fatalError() }
    ) -> Self {
        Self(count: count)
    }
}
