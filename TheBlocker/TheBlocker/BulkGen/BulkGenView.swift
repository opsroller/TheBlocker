//
//  BulkGenView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import SwiftUI
import ComposableArchitecture

/// Feature for generate large amount of phone numbers at once. Currently, only random generation is supported
struct BulkGen: View {
    let store: Store<BulkGenState, BulkGenAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: Text("Bulk Generate")) {
                // MARK: Text field for entering quantity
                TextField("Quantity", text: viewStore.binding(
                    get: { $0.quantityToGenerateAsString },
                    send: BulkGenAction.quantityChanged)
                ).keyboardType(.numberPad)
                // MARK: Generate button
                Button(action: { viewStore.send(.generate) }) {
                    generateButtonLabel(status: viewStore.status)
                }.disabled(viewStore.status == .working)
            }
        }
    }

    func generateButtonLabel(status: BulkGenState.Status) -> some View {
        HStack {
            Text("generate")
            if status == .working {
                ProgressView()
            } else if status == .success {
                Image(systemName: "checkmark.circle.fill")
            } else if status == .failure {
                Image(systemName: "xmark.octagon")
            }
        }
    }
}
