//
//  AppAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Root scene
enum AppAction: Equatable {
    case addNew(AddNewAction)
    case allowed(PhoneNumberListAction)
    case blocked(PhoneNumberListAction)
    case tabChangeTo(AppState.Tab)
    case callKit(CallKitAction)
}
