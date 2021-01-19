//
//  CallKitEnabledStatusView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/19/21.
//

import SwiftUI
import ComposableArchitecture

// Feature for interacting with CallKit framework and dispalying a warning that blocking is not enabled
struct CallKitEnabledStatus: View {
    let store: Store<CallKitState, CallKitAction>

    var body: some View {
        WithViewStore(store) { _ in
            Text("CallKit Blocking Extension Not Enabled!")
        }
    }
}
