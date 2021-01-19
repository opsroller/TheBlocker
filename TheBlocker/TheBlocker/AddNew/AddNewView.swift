//
//  AddNewView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import SwiftUI
import ComposableArchitecture

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
struct AddNew: View {
    let store: Store<AddNewState, AddNewAction>
    // Bring in CallKit feature for displaying enabled status in AddNew
    let callKitStore: Store<CallKitState, CallKitAction>

    var body: some View {
        Form {
            BulkGen(store: store.scope(
                state: { $0.bulkGen },
                action: { AddNewAction.bulkGen($0) }
            ))
            PhoneNumberForm(store: store.scope(
                state: { $0.form },
                action: { AddNewAction.form($0) }
            ))
            WithViewStore(callKitStore) { callKitViewStore in
                if !callKitViewStore.isExtensionEnabled {
                    CallKitEnabledStatus(store: callKitStore)
                }
            }
        }
    }
}
