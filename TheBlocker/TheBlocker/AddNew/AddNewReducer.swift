//
//  AddNewReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation
import ComposableArchitecture

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
let addNewReducer = Reducer<AddNewState, AddNewAction, AddNewEnv>.combine(
    bulkGenReducer.pullback(
        state: \AddNewState.bulkGen,
        action: /AddNewAction.bulkGen,
        environment: { BulkGenEnv(addNew: $0) }),
    phoneNumberFormReducer.pullback(
        state: \AddNewState.form,
        action: /AddNewAction.form,
        environment: { PhoneNumberFormEnv(addNew: $0) }
    )
)
