//
//  PhoneNumber.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import CallKit

/// Value type model for phone numbers. Used 'in the app' versus the reference type used in repositories
struct PhoneNumber: Hashable {
    private let value: Int64
    var isBlocked: Bool
    var created: Date?
    var lastModified: Date?
    var repoID: NSManagedObjectID?

    var asString: String { String(value) }

    var asCXPhoneNumber: CXCallDirectoryPhoneNumber { value }

    init(_ value: Int64, isBlocked: Bool = true, created: Date) {
        self.value = value
        self.created = created
        self.lastModified = created
        self.isBlocked = isBlocked
    }

    init?(_ value: String, isBlocked: Bool = true, created: Date) {
        guard let intValue = Int64(value) else { return nil }
        self.init(intValue, isBlocked: isBlocked, created: created)
    }
}

// MARK: Equatable conformance
extension PhoneNumber: Equatable {}

// MARK: Comparable conformance
extension PhoneNumber: Comparable {
    static func < (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        lhs.asCXPhoneNumber < rhs.asCXPhoneNumber
    }
}

// MARK: Identifiable conformance
extension PhoneNumber: Identifiable {
    var id: Int64 { value }
}

// MARK: UnmanagedModel conformance
extension PhoneNumber: UnmanagedModel {
    typealias RepoManaged = Repository.PhoneNumber

    init(_ repoNumber: RepoManaged) {
        self.value = repoNumber.value
        self.isBlocked = repoNumber.isBlocked
        self.created = repoNumber.created
        self.lastModified = repoNumber.lastModified
        self.repoID = repoNumber.objectID
    }

    func asRepoManaged(in context: NSManagedObjectContext) -> RepoManaged {
        let repoNumber = Repository.PhoneNumber(context: context)
        repoNumber.value = value
        repoNumber.isBlocked = isBlocked
        repoNumber.created = created
        repoNumber.lastModified = lastModified
        return repoNumber
    }
}

// MARK: Validation
extension PhoneNumber {
    /// `NSRegularExpression` for validating phone numbers less than 10 digits while being entered
    static let incompleteValidator: NSRegularExpression! = {
        do {
            return try NSRegularExpression(pattern: "^[2-9]?[0-9]{0,2}[2-9]?[0-9]{0,6}", options: .init())
        } catch {
            return nil
        }
    }()

    // Does allow length beyond 10 characters
    /// `NSRegularExpression` for validating a 10 digit phone number
    static let validator: NSRegularExpression! = {
        do {
            return try NSRegularExpression(pattern: "^[2-9]{1}[0-9]{2}[2-9]{1}[0-9]{6}", options: .init())
        } catch {
            return nil
        }
    }()

    static func isValid(_ value: String) -> Bool {
        Self.validator.matches(in: value, options: .init(), range: NSRange(location: 0, length: value.count)).count > 0
    }

    static func isIncompleteButValid(_ value: String) -> Bool {
        Self.incompleteValidator.matches(
            in: value,
            options: .init(),
            range: NSRange(location: 0, length: value.count)
        ).count > 0
    }

    /// Remove any trailing digits beyond 10
    static func trimLength(_ value: String) -> String {
        let lengthDiff = 10 - value.count
        if lengthDiff < 0 {
            return String(value.dropLast(abs(lengthDiff)))
        }
        return value
    }
}
