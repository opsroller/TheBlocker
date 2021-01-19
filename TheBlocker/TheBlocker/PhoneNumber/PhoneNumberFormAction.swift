//
//  PhoneNumberFormAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Foundation

// Feature for adding a blocked or allowed phone number
enum PhoneNumberFormAction: Equatable {
    case inputChanged(String)
    case submitted
    case repo(CRUDRepositoryAction<PhoneNumber>)
    case changedIsBlocked(Bool)
}
