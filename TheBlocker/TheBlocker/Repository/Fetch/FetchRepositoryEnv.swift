//
//  FetchRepositoryEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

struct FetchRepositoryEnv<Model: UnmanagedModel> {
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let repo: FetchRepositoryClientEffect<Model>
}

extension FetchRepositoryEnv {
    static func prod() -> Self {
        Self(
            mainQueue: .main,
            userInitSerialQueue: DispatchQueue.init(label: "userInitSerial", qos: .userInitiated),
            repo: .prod(.init(context: Repository.Stack.shared.newPrivateContext(name: "fetchRepository")))
        )
    }
}
