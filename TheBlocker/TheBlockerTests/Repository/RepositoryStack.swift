//
//  RepositoryStack.swift
//  TheBlockerTests
//
//  Created by Andrew Roan on 1/19/21.
//

import XCTest
import CoreData
@testable import TheBlocker

class RepositoryStackXCTestCase: XCTestCase {

    var context: NSManagedObjectContext {
        return Repository.Stack.testContext
    }
}

class TestRepository {}

extension Repository.Stack {
    private static var _model: NSManagedObjectModel?
    private static func model(name: String) throws -> NSManagedObjectModel {
        if _model == nil {
            _model = try loadModel(name: name, bundle: Bundle.main)
        }
        return _model!
    }
    private static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw fatalError()
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError()
       }
        return model
    }
    var testManagedObjectModel: NSManagedObjectModel {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        return managedObjectModel
    }

    static var testPersistantContainer: NSPersistentContainer {
        var oContainer: NSPersistentContainer?
        do {
            oContainer = NSPersistentContainer(
                name: "TheBlocker",
                managedObjectModel: try Self.model(name: "TheBlocker")
            )
        } catch {
            #if DEBUG
            print("Failed to create persistentContainer: \(error)")
            #endif
        }
        guard let container = oContainer else { fatalError() }
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            // Check if creating container wrong
            if let error = error {
                fatalError("In memory coordinator creation failed \(error)")
            }
        }
        return container
    }

    static var testContext: NSManagedObjectContext {
        return testPersistantContainer.viewContext
    }
}
