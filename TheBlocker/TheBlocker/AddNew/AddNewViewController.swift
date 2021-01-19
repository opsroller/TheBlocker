//
//  AddNewViewController.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import SwiftUI
import ComposableArchitecture

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
class AddNewController: UIHostingController<AddNew> {
    let store: Store<AddNewState, AddNewAction>
    let callKitStore: Store<CallKitState, CallKitAction>

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    init(store: Store<AddNewState, AddNewAction>, callKitStore: Store<CallKitState, CallKitAction>) {
        self.store = store
        self.callKitStore = callKitStore
        super.init(rootView: AddNew(store: store, callKitStore: callKitStore))
        self.tabBarItem = UITabBarItem(
            title: "Add New",
            image: UIImage(systemName: "goforward.plus"),
            tag: AppState.Tab.addNew.rawValue
        )
    }
}
