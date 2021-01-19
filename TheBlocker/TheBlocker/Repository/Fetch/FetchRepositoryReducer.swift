//
//  FetchRepositoryReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import ComposableArchitecture

extension Reducer {
    static func fetchRepository<Model: UnmanagedModel>() -> Reducer<
        FetchRepositoryState<Model>,
        FetchRepositoryAction<Model>,
        FetchRepositoryEnv<Model>
    > {
        return Reducer<
            FetchRepositoryState<Model>,
            FetchRepositoryAction<Model>,
            FetchRepositoryEnv<Model>
        > { state, action, env in
            switch action {
            case .fetch(let request):
                // Cache the most recent predicate and sort desc for fetchMore
                state.recentPredicate = request.predicate
                state.recentSortDesc = request.sortDesc
                return env.repo.fetch(request)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(FetchRepositoryAction<Model>.fetchResult)
            case .fetchSubscribe(let request):
                // Cache the most recent predicate and sort desc for fetchMore
                state.recentPredicate = request.predicate
                state.recentSortDesc = request.sortDesc
                return env.repo.fetchSubscription(request)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(FetchRepositoryAction<Model>.fetchResult)
                    .cancellable(id: state.fetchID)
            case .fetchResult(let result):
                switch result {
                case .success(.fetchSubscribe(let response)), .success(.fetch(let response)):
                    state.items = response.data
                    state.isFetching = false
                    return .none
                default:
                    return .none
                }
            case .fetchMore:
                state.fetchLimit += state.fetchPageSize
                return Effect(value: .fetch(state.fetchRequest(
                    predicate: state.recentPredicate,
                    sortDesc: state.recentSortDesc
                )))
            }
        }
    }
}
