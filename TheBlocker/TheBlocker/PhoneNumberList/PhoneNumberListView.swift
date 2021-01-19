//
//  PhoneNumberListView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import SwiftUI
import ComposableArchitecture

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
struct PhoneNumberList: View {
    let store: Store<PhoneNumberListState, PhoneNumberListAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            // MARK: Empty view if no data
            if viewStore.phoneNumbers.count == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Empty")
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                // MARK: List view for when there is data
                Section(header: Text("Total = \(viewStore.aggregateRepo.count)")) {
                    List {
                        ForEach(viewStore.phoneNumbers) { phoneNumber in
                            PhoneNumberListCellView(phoneNumber: phoneNumber)
                        }.onDelete(perform: { indexSet in
                            let numbersToDelete = indexSet.map { viewStore.phoneNumbers[$0] }
                            viewStore.send(PhoneNumberListAction.removeNumbers(numbersToDelete))
                        })
                        // MARK: Lazy fetch view for handling infinite scroll
                        LazyFetch(store: store.scope(state: { $0.fetchRepo }, action: PhoneNumberListAction.fetchRepo))
                    }
                }
            }

        }
    }
}
