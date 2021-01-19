//
//  AppReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation
import ComposableArchitecture

/// Root scene
let appReducer = Reducer<AppState, AppAction, AppEnv>.combine(
    // add new - bulk generation and phone number form
    addNewReducer.pullback(
        state: \AppState.addNew,
        action: /AppAction.addNew,
        environment: { AddNewEnv(app: $0) }
    ),
    // blocked list
    phoneNumberListReducer.pullback(
        state: \.blocked,
        action: /AppAction.blocked,
        environment: { PhoneNumberListEnv(app: $0) }
    ),
    // allowed list
    phoneNumberListReducer.pullback(
        state: \.allowed,
        action: /AppAction.allowed,
        environment: { PhoneNumberListEnv(app: $0) }
    ),
    // callkit
    callKitReducer.pullback(
        state: \AppState.callKit,
        action: /AppAction.callKit,
        environment: { CallKitEnv(app: $0) }
    ),
    Reducer { state, action, _ in
        switch action {
        case .tabChangeTo(let newTab):
            state.selectedTab = newTab
            return .none
        case .addNew(let addNewAction):
            switch addNewAction {
            // When adding phone numbers, update block list
            case .form(.repo(.repoResult(.success(.create)))),
                 .bulkGen(.generateResult(.success)):
                return .merge(
                    Effect(value: AppAction.blocked(.fetch)),
                    Effect(value: AppAction.allowed(.fetch)),
                    Effect(value: AppAction.callKit(.updateBlockList))
                )
            default:
                return .none
            }
        // When deleting phone numbers, update block list
        case .allowed(.crudRepo(.repoResult(.success(.delete)))),
             .blocked(.crudRepo(.repoResult(.success(.delete)))):
            return Effect(value: AppAction.callKit(.updateBlockList))
        default:
            return .none
        }
    }
)// .debugActions()
