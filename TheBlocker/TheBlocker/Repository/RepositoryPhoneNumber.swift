//
//  RepositoryPhoneNumber.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData

extension Repository {
    /// Persistence (CoreData) model for phone numbers. Ensure single thread access and wrap in context perform block.
    @objc(PhoneNumber)
    final class PhoneNumber: NSManagedObject {
        @NSManaged var value: Int64 // unique constraint in CoreData model
        @NSManaged var isBlocked: Bool
        @NSManaged var created: Date?
        @NSManaged var lastModified: Date?
    }
}

// MARK: NSEntity
extension Repository.PhoneNumber {
    /// Convenient access to entity name
    static let entityName = "PhoneNumber"

    /// Convenient access to specifically typed fetch request instead of default with NSFetchRequestResult
    static func fetchRequest() -> NSFetchRequest<Repository.PhoneNumber> {
        let fetchRequest = NSFetchRequest<Repository.PhoneNumber>(entityName: "PhoneNumber")
        fetchRequest.sortDescriptors = []
        return fetchRequest
    }
}

// MARK: Identifiable Conformance
extension Repository.PhoneNumber: Identifiable {
    /// Underlying phone number value. It's uniquely contrained so it works as an ID.
    var id: Int64 { value }
}

// MARK: RepositoryManagedModel Conformance
extension Repository.PhoneNumber: RepositoryManagedModel {
    typealias Unmanaged = PhoneNumber

    /// Convenient access for the corresponding value type.
    var asUnmanaged: Unmanaged {
        return Unmanaged(self)
    }

    /// Convenient access for updating `self` from the corresponding value type
    func update(from unmanaged: Unmanaged) {
        self.value = unmanaged.asCXPhoneNumber
        self.isBlocked = unmanaged.isBlocked
        self.created = unmanaged.created
        self.lastModified = unmanaged.lastModified
    }
}

// MARK: Predicates, Sort Descriptors
extension Repository.PhoneNumber {
    // Try to use comparison predicates where possible for type safety instead of string initializers for `NSPredicate`.

    /// Filters for values that are blocked: `isBlocked = true`
    static var blockedPredicate: NSPredicate {
        NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: \Repository.PhoneNumber.isBlocked),
            rightExpression: NSExpression(forConstantValue: true),
            modifier: .direct,
            type: .equalTo,
            options: []
        )
    }

    /// Filters for values that are not blocked: `isBlocked = false`
    static var allowedPredicate: NSPredicate {
        NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: \Repository.PhoneNumber.isBlocked),
            rightExpression: NSExpression(forConstantValue: false),
            modifier: .direct,
            type: .equalTo,
            options: []
        )
    }

    /// Filters for values that were last modified after the specified date: `lastModified > date`
    /// - Parameters
    ///     - `after date: Date`
    /// - Returns
    ///     - `NSPredicate`
    static func lastModified(after date: Date) -> NSPredicate {
        NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: \Repository.PhoneNumber.lastModified),
            rightExpression: NSExpression(forConstantValue: date),
            modifier: .direct,
            type: .greaterThan,
            options: []
        )
    }

    /// Phone numbers are currently always sorted as ascending
    static var defaultSort: [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \Repository.PhoneNumber.value, ascending: true)]
    }
}
