//
//  AggregateRepositoryReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import ComposableArchitecture

extension Reducer {
    static func aggregateRepository<Model: UnmanagedModel>() -> Reducer<
        AggregateRepositoryState<Model>,
        AggregateRepositoryAction<Model>,
        AggregateRepositoryEnv<Model>
    > {
        return Reducer<
            AggregateRepositoryState,
            AggregateRepositoryAction<Model>,
            AggregateRepositoryEnv<Model>
        > { state, action, env in
            switch action {
            case .count(let request):
                state.isWorking = true
                return env.repo.count(request)
                    .subscribe(on: env.userInitSerialQueue)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(AggregateRepositoryAction<Model>.aggregateResult)
            case .aggregateResult(let result):
                switch result {
                case .success(.count(let count)):
                    state.count = count
                    state.isWorking = false
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
