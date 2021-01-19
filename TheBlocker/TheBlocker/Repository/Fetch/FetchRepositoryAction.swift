//
//  FetchRepositoryAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import ComposableArchitecture

enum FetchRepositoryAction<Model: UnmanagedModel>: Equatable {
    case fetch(FetchRequest<Model>)
    case fetchSubscribe(FetchRequest<Model>)
    case fetchResult(Result<Repository.Fetch.Success<Model>, Repository.Fetch.Failure<Model>>)
    case fetchMore
}
