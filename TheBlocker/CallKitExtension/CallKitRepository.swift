//
//  CallKitRepository.swift
//  CallKitExtension
//
//  Created by Andrew Roan on 1/18/21.
//

import CoreData
import CallKit

// Fetching phone numbers for CallKit Extension
extension Repository.Fetch {

    // MARK: Fetch All
    private static let allBlocked: NSFetchRequest<Repository.PhoneNumber> = {
        let request: NSFetchRequest<Repository.PhoneNumber> = Repository.PhoneNumber.fetchRequest()
        request.predicate = Repository.PhoneNumber.blockedPredicate
        request.propertiesToFetch = ["value"]
        request.sortDescriptors = Repository.PhoneNumber.defaultSort
        return request
    }()

    func fetchAllBlocked() -> [CXCallDirectoryPhoneNumber] {
        var numbers = [CXCallDirectoryPhoneNumber]()
        self.context.performAndWait {
            do {
                numbers = try self.context.fetch(Self.allBlocked).map { $0.value }
            } catch {
                #if DEBUG
                print("\(#function)\(#line) - failed to fetch allBlocked - \(error.localizedDescription)")
                #endif
            }
        }
        return numbers
    }

    // MARK: Incremental Fetch
    private func incrementalBlockToAdd(from date: Date) -> NSFetchRequest<Repository.PhoneNumber> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            Repository.PhoneNumber.blockedPredicate,
            Repository.PhoneNumber.lastModified(after: date)
        ])
        let request: NSFetchRequest<Repository.PhoneNumber> = Repository.PhoneNumber.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = Repository.PhoneNumber.defaultSort
        request.propertiesToFetch = ["value"]
        return request
    }

    func fetchIncrementalBlockedToAdd(from date: Date) -> [CXCallDirectoryPhoneNumber] {
        var numbers = [CXCallDirectoryPhoneNumber]()
        do {
            numbers = try self.context.fetch(incrementalBlockToAdd(from: date)).map { $0.value }
        } catch {
            #if DEBUG
            print("\(#function)\(#line) - failed to fetch incrementalBlockedToAdd - \(error.localizedDescription)")
            #endif
        }
        return numbers
    }

    func fetchIncrementalBlockedToRemove(from date: Date) -> [CXCallDirectoryPhoneNumber] {

        guard let lastUpdated = UserDefaultsRepositoryClient.prod.getLastBlockListUpdate() else { return [] }
        let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastUpdated)
        guard let historyResult = try? self.context.execute(request) as? NSPersistentHistoryResult,
              let history = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            #if DEBUG
            print("\(#function) - failed to fetch persistent history")
            #endif
            return []
        }
        var remove = [CXCallDirectoryPhoneNumber]()
        for transaction in history {
            for change in transaction.changes ?? [] {
                switch change.changeType {
                case .delete:
                    if let tombstone = change.tombstone,
                       let value = tombstone["value"] as? CXCallDirectoryPhoneNumber {
                        remove.append(value)
                    }
                default:
                    break
                }
            }
        }

        return remove
    }

    func purgeHistory(before date: Date) {
        let purgeHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: date)
        do {
            try self.context.execute(purgeHistoryRequest)
        } catch {
            #if DEBUG
            print("\(#function) - \(error.localizedDescription)")
            #endif
        }
    }
}

// MARK: Client
/// Dependency injection adapter of fetch repository for CallKit extension
struct CallKitRepositoryClient {
    let fetchAllBlocked: () -> [CXCallDirectoryPhoneNumber]
    let fetchIncrementalBlockedToAdd: (Date) -> [CXCallDirectoryPhoneNumber]
    let fetchIncrementalBlockedToRemove: (Date) -> [CXCallDirectoryPhoneNumber]
    let purgeHistory: (Date) -> Void
}

// MARK: Client production instance
extension CallKitRepositoryClient {
    // Static instance intended for production use
    static let prod: Self = {
        let repo = Repository.Fetch(context: Repository.Stack.shared.newPrivateContext(name: "callKit"))
        return Self(
            fetchAllBlocked: repo.fetchAllBlocked,
            fetchIncrementalBlockedToAdd: repo.fetchIncrementalBlockedToAdd,
            fetchIncrementalBlockedToRemove: repo.fetchIncrementalBlockedToRemove,
            purgeHistory: repo.purgeHistory
        )
    }()
}
