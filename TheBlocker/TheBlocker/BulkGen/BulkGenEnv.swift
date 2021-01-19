//
//  BulkGenEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation

/// Feature for generate large amount of phone numbers at once. Currently, only random generation is supported
struct BulkGenEnv {
    let phoneNumberGen: PhoneNumberGeneratorClientEffect
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let crudRepo: CRUDRepositoryClientEffect<PhoneNumber>
    let date: (() -> Date)
}

extension BulkGenEnv {
    static func prod(
        _ generator: PhoneNumberGeneratorClientEffect,
        userInitSerialQueue: DispatchQueue = .init(label: "userInitSerial", qos: .userInitiated),
        crudRepo: CRUDRepositoryClientEffect<PhoneNumber>,
        date: @escaping (() -> Date) = Date.init
    ) -> Self {
        Self(
            phoneNumberGen: generator,
            mainQueue: .main,
            userInitSerialQueue: userInitSerialQueue,
            crudRepo: crudRepo,
            date: date
        )
    }
}

extension BulkGenEnv {
    init(addNew: AddNewEnv) {
        self.phoneNumberGen = addNew.phoneNumberGen
        self.mainQueue = addNew.mainQueue
        self.userInitSerialQueue = addNew.userInitSerialQueue
        self.crudRepo = addNew.crudRepo
        self.date = addNew.date
    }
}
