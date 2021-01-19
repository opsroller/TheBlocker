//
//  CallKitRequestUpdate.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import CallKit
import Combine
import ComposableArchitecture
import CoreData

/// Service for interacting with CallKit on the app side via `CXCallDirectoryManager`
class CallKitService {
    // TODO: I don't like having this string literal here. Can I
    //  access the extension bundle id from the app?
    static let extensionBundleID = "com.roanwell.TheBlocker.CallKitExtension"

    // MARK: Result types
    /// The success type for successful results
    enum Success: Equatable {
        case requestUpdate
        case getEnabledStatus(Bool)
    }

    /// The failure type for failed results
    enum Failure: Equatable, Error {
        case requestUpdate
    }

    // API End points
    /// Requests the system to update the block list via the CallKit extension
    /// - Returns:
    ///     - `Effect<Success, Failure`
    static func requestUpdate() -> Effect<Success, Failure> {
        Future { callback in
            CXCallDirectoryManager.sharedInstance
                .reloadExtension(
                    withIdentifier: Self.extensionBundleID,
                    completionHandler: { error in
                        if error != nil {
                            callback(.failure(.requestUpdate))
                        } else {
                            callback(.success(.requestUpdate))
                        }
            })
        }.eraseToEffect()
    }

    /// Gets the enabled status of the CallKit blocking extension
    /// - Returns
    ///     - `Effect<Success, Never>`
    static func getEnabledStatus() -> Effect<Success, Never> {
        Future { callback in
            CXCallDirectoryManager.sharedInstance
                .getEnabledStatusForExtension(
                    withIdentifier: Self.extensionBundleID,
                    completionHandler: { status, _  in
                        // Don't care if it's an error. Just tell me if it's enabled or not.
                        // In the future more granular handling including error propogation to user can be added.
                        if status == .enabled {
                            callback(.success(.getEnabledStatus(true)))
                        } else {
                            callback(.success(.getEnabledStatus(false)))
                        }
                    })
        }.eraseToEffect()
    }

    // TODO: Add endpoint for navigating to settings app for enabling extension
}

// MARK: Effect Client
/// Dependency injection adapter for `CallKitService`
struct CallKitServiceClientEffect {
    /// Requests the system to update the block list via the CallKit extension
    /// - Returns:
    ///     - `Effect<CallKitService.Success, CallKitService.Failure`
    let requestUpdate: () -> Effect<CallKitService.Success, CallKitService.Failure>

    /// Gets the enabled status of the CallKit blocking extension
    /// - Returns
    ///     - `Effect<Success, Never>`
    let getEnabledStatus: () -> Effect<CallKitService.Success, Never>
}

// MARK: Effect plient production instance
extension CallKitServiceClientEffect {
    /// The static instance intended for production use.
    static let prod = Self(requestUpdate: CallKitService.requestUpdate, getEnabledStatus: CallKitService.getEnabledStatus)
}

// MARK: Repository update pipeline
extension Repository.Stack {
    func startCallKitUpdating(
        context: NSManagedObjectContext = shared.repoContext,
        client: CallKitServiceClientEffect = .prod
    ) {
        self.callKitExtUpdater = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { _ in _ = client.requestUpdate() }
    }
}
