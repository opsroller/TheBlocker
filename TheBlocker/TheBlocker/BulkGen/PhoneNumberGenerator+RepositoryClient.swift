//
//  PhoneNumberGeneratorRepositoryClient.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation
import Combine
import CoreData

// MARK: Repository Client
extension PhoneNumberGenerator {
    /// Dependency injection adapter for persistence
    struct RepositoryClient {
        /// Inserts generated numbers into persistent store with batch insert
        /// - Parameters
        ///     - `Set<Int64>`
        /// - Returns
        ///     - `AnyPublisher<Success, Failure>`
        let insert: (Set<Int64>) -> AnyPublisher<Success, Failure>
    }
}

// TODO: Handle edge case for when requested quantity isn't inserted because of duplicate
//  values already in storage.
// MARK: Production Instance of Repository Client
extension PhoneNumberGenerator.RepositoryClient {
    typealias Success = Repository.BatchInsert.Success
    typealias Failure = Repository.BatchInsert.Failure

    static func prod(date: (@escaping () -> Date) = Date.init, batchInsertRepo: BatchInsertRepositoryClient) -> Self {
        Self(
            insert: { phoneNumbers in
                let entityName = Repository.PhoneNumber.entityName
                let now = date()
                // Map phone numbers into a dictionary for repository batch insert method
                let data: [[String: Any]] = phoneNumbers.map { phoneNumber in
                    ["value": phoneNumber, "created": now, "lastModified": now, "isBlocked": true] }
                return batchInsertRepo.insert(data, entityName)
            }
        )
    }
}
