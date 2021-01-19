//
//  AggregateRepositoryEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

struct AggregateRepositoryEnv<Model: UnmanagedModel> {
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let repo: AggregateRepositoryClientEffect<Model>
}

extension AggregateRepositoryEnv {
    static func prod() -> Self {
        Self(
            mainQueue: .main,
            userInitSerialQueue: DispatchQueue.init(label: "userInitSerial", qos: .userInitiated),
            repo: .prod(.init(context: Repository.Stack.shared.newPrivateContext(name: "fetchRepository")))
        )
    }
}
