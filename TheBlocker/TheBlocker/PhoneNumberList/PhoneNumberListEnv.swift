//
//  PhoneNumberListEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
struct PhoneNumberListEnv {
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let fetchRepo: FetchRepositoryClientEffect<PhoneNumber>
    let crudRepo: CRUDRepositoryClientEffect<PhoneNumber>
    let aggregateRepo: AggregateRepositoryClientEffect<PhoneNumber>
}

// MARK: Static instance for production
extension PhoneNumberListEnv {
    /// Static instance intended for production use
    static func prod(
        mainQueue: DispatchQueue = .main,
        userInitSerialQueue: DispatchQueue = .userInitSerial,
        fetchRepo: FetchRepositoryClientEffect<PhoneNumber>,
        crudRepo: CRUDRepositoryClientEffect<PhoneNumber>,
        aggregateRepo: AggregateRepositoryClientEffect<PhoneNumber>
    ) -> Self {
        Self(
            mainQueue: mainQueue,
            userInitSerialQueue: userInitSerialQueue,
            fetchRepo: fetchRepo,
            crudRepo: crudRepo,
            aggregateRepo: aggregateRepo
        )
    }
}

// MARK: Init adapters for parent environments
extension PhoneNumberListEnv {
    init(app: AppEnv) {
        self.mainQueue = app.mainQueue
        self.userInitSerialQueue = app.userInitSerialQueue
        self.fetchRepo = app.fetchRepo
        self.crudRepo = app.crudRepo
        self.aggregateRepo = app.aggregateRepo
    }
}

extension FetchRepositoryEnv where Model == PhoneNumber {
    init(phoneNumberList: PhoneNumberListEnv) {
        self.init(
            mainQueue: phoneNumberList.mainQueue,
            userInitSerialQueue: phoneNumberList.userInitSerialQueue,
            repo: phoneNumberList.fetchRepo
        )
    }
}

extension CRUDRepositoryEnv where Model == PhoneNumber {
    init(phoneNumberList: PhoneNumberListEnv) {
        self.init(
            mainQueue: phoneNumberList.mainQueue,
            userInitSerialQueue: phoneNumberList.userInitSerialQueue,
            repo: phoneNumberList.crudRepo
        )
    }
}

extension AggregateRepositoryEnv where Model == PhoneNumber {
    init(phoneNumberList: PhoneNumberListEnv) {
        self.init(
            mainQueue: phoneNumberList.mainQueue,
            userInitSerialQueue: phoneNumberList.userInitSerialQueue,
            repo: phoneNumberList.aggregateRepo
        )
    }
}
