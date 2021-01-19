//
//  CRUDRepositoryEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

struct CRUDRepositoryEnv<Model: UnmanagedModel> {
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let repo: CRUDRepositoryClientEffect<Model>
}

extension CRUDRepositoryEnv {
    static func prod() -> Self {
        Self(
            mainQueue: .main,
            userInitSerialQueue: DispatchQueue.init(label: "userInitSerial", qos: .userInitiated),
            repo: .prod(.init(context: Repository.Stack.shared.newPrivateContext(name: "crudRepository")))
        )
    }
}
