//
//  AppEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation

/// Root scene
struct AppEnv {
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let fetchRepo: FetchRepositoryClientEffect<PhoneNumber>
    let phoneNumberGen: PhoneNumberGeneratorClientEffect
    let date: () -> Date
    let crudRepo: CRUDRepositoryClientEffect<PhoneNumber>
    let callKitService: CallKitServiceClientEffect
    let aggregateRepo: AggregateRepositoryClientEffect<PhoneNumber>
}

extension AppEnv {
    /// Static instance intended for production use
    static func prod(
        mainQueue: DispatchQueue = .main,
        userInitSerialQueue: DispatchQueue = .userInitSerial,
        fetchRepo: FetchRepositoryClientEffect<PhoneNumber>,
        phoneNumberGen: PhoneNumberGeneratorClientEffect,
        date: @escaping (() -> Date) = Date.init,
        crudRepo: CRUDRepositoryClientEffect<PhoneNumber>,
        callKitService: CallKitServiceClientEffect = .prod,
        aggregateRepo: AggregateRepositoryClientEffect<PhoneNumber>
    ) -> Self {
        Self(
            mainQueue: mainQueue,
            userInitSerialQueue: userInitSerialQueue,
            fetchRepo: fetchRepo,
            phoneNumberGen: phoneNumberGen,
            date: date,
            crudRepo: crudRepo,
            callKitService: callKitService,
            aggregateRepo: aggregateRepo
        )
    }
}

extension DispatchQueue {
    /// The 'background' queue. Must be serial for `Combine` framework.
    static let userInitSerial = DispatchQueue(label: "userInitSerial", qos: .userInitiated)
}
