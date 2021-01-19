//
//  PhoneNumberFormView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import SwiftUI
import ComposableArchitecture

// Feature for adding a blocked or allowed phone number
struct PhoneNumberForm: View {
    let store: Store<PhoneNumberFormState, PhoneNumberFormAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: Text("One at a Time")) {
                VStack {

                    // MARK: Blocked vs Allowed Picker
                    Picker("", selection: viewStore.binding(
                        get: { $0.isBlocked },
                        send: { PhoneNumberFormAction.changedIsBlocked($0) }
                    )) {
                        Text("Block").tag(true)
                        Text("Allow").tag(false)
                    }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                    // MARK: Textfield and valid indicator
                    HStack {
                        if viewStore.isValid {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "xmark.octagon")
                        }
                        Text("+1")
                        TextField(
                            "Phone Number",
                            text: viewStore.binding(
                                get: { $0.userInput },
                                send: { PhoneNumberFormAction.inputChanged($0) }
                            )
                        )
                    }
                    // MARK: Submit button
                    Button(action: { viewStore.send(PhoneNumberFormAction.submitted) }) {
                        Text("Submit")
                    }.disabled(!viewStore.isValid)
                }
            }
        }
    }
}
