//
//  PhoneNumberListController.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import SwiftUI
import ComposableArchitecture

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
/// UIHostingController adapter between the root `UITabBarController` and the `SwiftUI` views.
class PhoneNumberListController: UIHostingController<PhoneNumberList> {
    let store: Store<PhoneNumberListState, PhoneNumberListAction>
    let viewStore: ViewStore<PhoneNumberListState, PhoneNumberListAction>
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(tag: Int, title: String, image: UIImage, store: Store<PhoneNumberListState, PhoneNumberListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(rootView: PhoneNumberList(store: store))
        self.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
    }
}

extension PhoneNumberListController {
    static func blocked(store: Store<PhoneNumberListState, PhoneNumberListAction>) -> PhoneNumberListController {
        .init(
            tag: AppState.Tab.blocked.rawValue,
            title: "Blocked",
            image: UIImage(systemName: "phone.down.circle")!,
            store: store
        )
    }

    static func allowed(store: Store<PhoneNumberListState, PhoneNumberListAction>) -> PhoneNumberListController {
        .init(
            tag: AppState.Tab.allowed.rawValue,
            title: "Allowed",
            image: UIImage(systemName: "phone.circle")!,
            store: store
        )
    }
}
