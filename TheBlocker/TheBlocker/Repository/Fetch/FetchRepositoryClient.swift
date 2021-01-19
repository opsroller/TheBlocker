//
//  FetchRepositoryClient.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import Combine

struct FetchRepositoryClient<Model: UnmanagedModel> {
    typealias Success = Repository.Fetch.Success<Model>
    typealias Failure = Repository.Fetch.Failure<Model>
    let fetch: (FetchRequest<Model>) -> Future<Success, Failure>
    let fetchSubscription: (FetchRequest<Model>) -> PassthroughSubject<Success, Failure>
}

extension FetchRepositoryClient {
    static func prod(_ repo: Repository.Fetch) -> Self {
        Self(fetch: repo.fetch, fetchSubscription: repo.fetchSubscribed)
    }
}

extension FetchRepositoryClient {
    static func mock(
        fetch: @escaping (FetchRequest<Model>) -> Future<Success, Failure> = { _ in fatalError() },
        fetchSubscription: @escaping (FetchRequest<Model>) -> PassthroughSubject<Success, Failure> = { _ in
            fatalError()
        }
    ) -> Self {
        Self(fetch: fetch, fetchSubscription: fetchSubscription)
    }
}
