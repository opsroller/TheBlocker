//
//  AppViewController.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import UIKit
import Combine
import ComposableArchitecture

/// Root view controller contained by SceneDelegate
class AppViewController: UITabBarController {
    let store: Store<AppState, AppAction>
    let viewStore: ViewStore<AppState, AppAction>
    var cancellables = [AnyCancellable]()

    // MARK: Child view controllers
    lazy var addNew = AddNewController(
        store: self.store.scope(state: { $0.addNew }, action: { AppAction.addNew($0) }),
        callKitStore: store.scope(state: { $0.callKit }, action: { AppAction.callKit($0) })
    )
    lazy var blocked = PhoneNumberListController.blocked(
        store: self.store.scope(state: { $0.blocked }, action: { AppAction.blocked($0) }))
    lazy var allowed = PhoneNumberListController.allowed(
        store: self.store.scope(state: { $0.allowed }, action: { AppAction.allowed($0) }))

    // MARK: NSCoder init - Not implemented
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    // MARK: Init
    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [self.addNew, self.blocked, self.allowed]
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewStore.publisher.selectedTab.sink { [weak self] tab in
            guard let self = self else { return }
            // Change TabBar to match state
            self.selectedIndex = tab.rawValue
        }.store(in: &self.cancellables)
    }

    // MARK: TabBar delegate conformance
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Change state to match selected tab
        self.viewStore.send(.tabChangeTo(AppState.Tab(rawValue: item.tag) ?? .addNew))
    }

    // MARK: deinit
    deinit {
        // cancel all Combine pipelines on deinit. All should reference `self` weakly.
        self.cancellables.forEach { $0.cancel() }
    }
}
