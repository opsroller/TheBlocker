//
//  CallKitReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/19/21.
//

import Foundation
import ComposableArchitecture

// Feature for interacting with CallKit framework and dispalying a warning that blocking is not enabled
let callKitReducer = Reducer<CallKitState, CallKitAction, CallKitEnv> { state, action, env in
    switch action {
    case .getEnabledStatus:
        return env.service.getEnabledStatus()
            .map { result in
                switch result {
                case .getEnabledStatus(let status):
                return status
                default:
                    return false
                }
            }
            .map(CallKitAction.getEnabledStatusResponse)
    case .getEnabledStatusResponse(let status):
        state.isExtensionEnabled = status
        return .none
    case .updateBlockList:
        return env.service.requestUpdate()
            .catchToEffect()
            .map(CallKitAction.result)
    default:
        return .none
    }
}
