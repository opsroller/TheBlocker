//
//  Stack.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import Combine

extension Repository {
    final class Stack: NSObject {
        public static let shared = Stack()
        let dbName = "TheBlocker"
        let groupID: String = BundleInfoProvider.prod.groupId
        let mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        lazy var repoContext: NSManagedObjectContext = self.newPrivateContext(name: "repository")
        var callKitExtUpdater: AnyCancellable?

        lazy var persistentContainer: NSPersistentContainer = {
            let storeURL = URL.storeURL(for: groupID, databaseName: dbName)
            let container = NSPersistentContainer(name: dbName)
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
            container.loadPersistentStores(completionHandler: { storeDescription, error in
                guard error == nil else {
                    assertionFailure(
                        "Persistent store '\(storeDescription)' failed loading: \(String(describing: error))")
                    return
                }
            })
            // Enable history tracking for add/remove in CallKit
            let description = container.persistentStoreDescriptions.first
            description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            container.viewContext.name = "viewContext"

            // CoreData model unique contraint requires a merge policy
            container.viewContext.mergePolicy = self.mergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
            return container
        }()

        lazy var viewContext = persistentContainer.viewContext

        func newPrivateContext(name: String) -> NSManagedObjectContext {
            let context = persistentContainer.newBackgroundContext()
            context.name = name
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = self.mergePolicy
            return context
        }

        func save(context: NSManagedObjectContext) -> Error? {
            var saveError: Error?
            context.performAndWait {
                guard context.hasChanges else { return }
                do {
                    try context.save()
                } catch {
                    saveError = error
                }
            }
            return saveError
        }
    }
}

// MARK: Persistent History Token
extension Repository.Stack {
    /// Latest peristent history token
    var historyToken: NSPersistentHistoryToken? {
        let coordinator = self.persistentContainer.persistentStoreCoordinator
        return coordinator.currentPersistentHistoryToken(fromStores: coordinator.persistentStores)
    }
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
