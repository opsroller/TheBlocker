//
//  CallKitAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/19/21.
//

import Foundation

// Feature for interacting with CallKit framework and dispalying a warning that blocking is not enabled
enum CallKitAction: Equatable {
    case updateBlockList
    case getEnabledStatus
    case getEnabledStatusResponse(Bool)
    case result(Result<CallKitService.Success, CallKitService.Failure>)
}
