//
//  PhoneNumberFormEnv.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation

// Feature for adding a blocked or allowed phone number
struct PhoneNumberFormEnv {
    let repo: CRUDRepositoryClientEffect<PhoneNumber>
    let date: () -> Date
    let mainQueue: DispatchQueue
    let userInitSerialQueue: DispatchQueue
}

// MARK: Init adapters for parent environments
extension PhoneNumberFormEnv {
    init(addNew: AddNewEnv) {
        self.repo = addNew.crudRepo
        self.date = addNew.date
        self.mainQueue = addNew.mainQueue
        self.userInitSerialQueue = addNew.userInitSerialQueue
    }
}

extension CRUDRepositoryEnv where Model == PhoneNumber {
    init(phoneNumberForm: PhoneNumberFormEnv) {
        self.mainQueue = phoneNumberForm.mainQueue
        self.repo = phoneNumberForm.repo
        self.userInitSerialQueue = phoneNumberForm.userInitSerialQueue
    }
}
