//
//  BulkGenState.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Feature for generate large amount of phone numbers at once. Currently, only random generation is supported
struct BulkGenState: Equatable {
    var quantityToGenerate: Int = 1000
    var quantityToGenerateAsString: String {
        get { String(quantityToGenerate) }
        set { quantityToGenerate = Int(newValue) ?? quantityToGenerate }
    }
    /// Reflects the activity status of the bulk generator.
    var status: Status = .idle

    /// Reflects the activity status of the bulk generator.
    enum Status: Equatable {
        case working, success, failure, idle
    }
}
