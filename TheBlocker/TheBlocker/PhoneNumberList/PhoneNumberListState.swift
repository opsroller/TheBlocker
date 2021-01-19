//
//  PhoneNumberListState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

// MARK: PhoneNumberListState
/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
struct PhoneNumberListState: Equatable {
    var fetchRepo: FetchRepositoryState<PhoneNumber>
    var crudRepo: CRUDRepositoryState
    var aggregateRepo: AggregateRepositoryState<PhoneNumber>
    var phoneNumbers: [PhoneNumber] {
        get { fetchRepo.items }
        set { fetchRepo.items = newValue }
    }
    var predicate: NSPredicate
    var sort: [NSSortDescriptor]
}

// MARK: Static instances for both blocked, allowed lists
extension PhoneNumberListState {
    static let blocked = Self(
        fetchRepo: .init(fetchID: "blockedFetch"),
        crudRepo: .init(),
        aggregateRepo: .init(fetchID: "blockedCount"),
        predicate: Repository.PhoneNumber.blockedPredicate,
        sort: Repository.PhoneNumber.defaultSort
    )

    static let allowed = Self(
        fetchRepo: .init(fetchID: "allowedFetch"),
        crudRepo: .init(),
        aggregateRepo: .init(fetchID: "allowedCount"),
        predicate: Repository.PhoneNumber.allowedPredicate,
        sort: Repository.PhoneNumber.defaultSort
    )
}
