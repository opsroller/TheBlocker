//
//  AddNewEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
struct AddNewEnv {
    let phoneNumberGen: PhoneNumberGeneratorClientEffect
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
    let crudRepo: CRUDRepositoryClientEffect<PhoneNumber>
    let date: (() -> Date)
}

extension AddNewEnv {
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

extension AddNewEnv {
    init(app: AppEnv) {
        self.phoneNumberGen = app.phoneNumberGen
        self.mainQueue = app.mainQueue
        self.userInitSerialQueue = app.userInitSerialQueue
        self.crudRepo = app.crudRepo
        self.date = app.date
    }
}
