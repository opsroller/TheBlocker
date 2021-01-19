//
//  AddNewState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
struct AddNewState: Equatable {
    var bulkGen: BulkGenState = .init()
    var form: PhoneNumberFormState = .init()
}
