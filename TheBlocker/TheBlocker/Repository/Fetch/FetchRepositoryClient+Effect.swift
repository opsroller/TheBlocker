//
//  FetchRepositoryClient+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import Combine
import ComposableArchitecture

struct FetchRepositoryClientEffect<Model: UnmanagedModel> {
    typealias Success = Repository.Fetch.Success<Model>
    typealias Failure = Repository.Fetch.Failure<Model>
    let fetch: (FetchRequest<Model>) -> Effect<Success, Failure>
    let fetchSubscription: (FetchRequest<Model>) -> Effect<Success, Failure>
}

extension FetchRepositoryClientEffect {
    static func prod(_ repo: Repository.Fetch) -> Self {
        Self(fetch: repo.fetch, fetchSubscription: repo.fetchSubscribed)
    }
}

extension FetchRepositoryClientEffect {
    static func mock(
        fetch: @escaping (FetchRequest<Model>) -> Effect<Success, Failure> = { _ in fatalError() },
        fetchSubscription: @escaping (FetchRequest<Model>) -> Effect<Success, Failure> = { _ in
            fatalError()
        }
    ) -> Self {
        Self(fetch: fetch, fetchSubscription: fetchSubscription)
    }
}
