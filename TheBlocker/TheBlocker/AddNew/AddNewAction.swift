//
//  AddNewAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation

/// A top level scene that contains generating numbers in bulk and manually adding individual numbers
enum AddNewAction: Equatable {
    case bulkGen(BulkGenAction)
    case form(PhoneNumberFormAction)
}
