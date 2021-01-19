//
//  AppState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Root scene
struct AppState: Equatable {
    var selectedTab: Tab = .addNew
    var addNew: AddNewState = .init()
    var blocked: PhoneNumberListState = .blocked
    var allowed: PhoneNumberListState = .allowed
    var callKit: CallKitState = .init()

    /// State for modeling the tabs in UITabBarController
    enum Tab: Int, Equatable {
        case addNew
        case blocked
        case allowed
    }
}

extension AppState {
    /// Static instance intended for production
    static let prod = AppState()
}
