//
//  AggregateRepository+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import CoreData
import Combine
import ComposableArchitecture

extension Repository.Aggregate {
    func count<Model: UnmanagedModel>(_ request: FetchRequest<Model>) -> Effect<Success, Failure<Model>> {
        let future: Future<Success, Failure<Model>> = self.count(request)
        return future.eraseToEffect()
    }
}
