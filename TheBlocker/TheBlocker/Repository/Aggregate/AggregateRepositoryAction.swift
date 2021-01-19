//
//  AggregateRepositoryAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

enum AggregateRepositoryAction<Model: UnmanagedModel>: Equatable {
    case count(FetchRequest<Model>)
    case aggregateResult(Result<Repository.Aggregate.Success, Repository.Aggregate.Failure<Model>>)
}
