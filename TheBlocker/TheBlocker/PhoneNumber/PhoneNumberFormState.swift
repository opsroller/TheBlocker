//
//  PhoneNumberFormState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Foundation

// Feature for adding a blocked or allowed phone number
struct PhoneNumberFormState: Equatable {
    var userInput: String = ""
    var repo: CRUDRepositoryState = .init()
    var isValid: Bool = false
    var isBlocked: Bool = true
}
