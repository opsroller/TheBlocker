//
//  BulkGenAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Feature for generate large amount of phone numbers at once. Currently, only random generation is supported
enum BulkGenAction: Equatable {
    case generate
    case generateResult(Result<PhoneNumberGenerator.Success, PhoneNumberGenerator.Failure>)
    case quantityChanged(String)
}
