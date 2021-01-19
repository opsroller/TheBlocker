//
//  SceneDelegate.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import UIKit
import SwiftUI
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // MARK: Init environment
        let context = Repository.Stack.shared.newPrivateContext(name: "repository")
        let fetchRepo = FetchRepositoryClientEffect<PhoneNumber>.prod(.init(context: context))
        let crudRepo = CRUDRepositoryClientEffect<PhoneNumber>.prod(.init(context: context))
        let aggregateRepo = AggregateRepositoryClientEffect<PhoneNumber>.prod(.init(context: context))
        let phoneNumberGenRepo = PhoneNumberGenerator.RepositoryClient.prod(batchInsertRepo: .prod(context: context))
        let phoneNumberGen = PhoneNumberGeneratorClientEffect.prod(generator: .prod(repository: phoneNumberGenRepo))
        let appEnv = AppEnv.prod(
            fetchRepo: fetchRepo,
            phoneNumberGen: phoneNumberGen,
            crudRepo: crudRepo,
            aggregateRepo: aggregateRepo
        )
        // MARK: Init root store
        let store = Store<AppState, AppAction>(initialState: .prod, reducer: appReducer, environment: appEnv)
        let viewStore = ViewStore(store)
        // MARK: Fetch phone numbers so they're populated already
        viewStore.send(.blocked(.fetch))
        viewStore.send(.allowed(.fetch))
        // MARK: Check CallKit Extension Status
        viewStore.send(.callKit(.getEnabledStatus))

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = AppViewController(store: store)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        /*
         Called as the scene is being released by the system.
         This occurs shortly after the scene enters the background, or when its session is discarded.
         Release any resources associated with this scene that can be re-created the next time the scene connects.
         The scene may re-connect later, as its session was not necessarily discarded (see
            `application:didDiscardSceneSessions` instead).
         */
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
