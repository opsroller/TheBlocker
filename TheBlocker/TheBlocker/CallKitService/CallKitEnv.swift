//
//  CallKitEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/19/21.
//

import Foundation

// Feature for interacting with CallKit framework and dispalying a warning that blocking is not enabled
struct CallKitEnv {
    let service: CallKitServiceClientEffect
}

// Production instance
extension CallKitEnv {
    static let prod = Self(service: CallKitServiceClientEffect.prod)
}

// MARK: Parent init adapter
extension CallKitEnv {
    init(app: AppEnv) {
        self.service = app.callKitService
    }
}
