//
//  BulkGenReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation
import ComposableArchitecture

extension ClosedRange where Bound == Int {
    // swiftlint:disable identifier_name
    /// Constant defining the allowed range of bulk generation quantity.
    /// Specification requested `1,000-100,000` inclusive.
    static let PHONE_NUMBER_GEN_QUANT = 1_000...100_000
}

/// Feature for generate large amount of phone numbers at once. Currently, only random generation is supported
let bulkGenReducer = Reducer<BulkGenState, BulkGenAction, BulkGenEnv> { state, action, env in
    switch action {
    case .generate:
        state.status = .working
        return env.phoneNumberGen.random(state.quantityToGenerate)
            .subscribe(on: env.userInitSerialQueue)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(BulkGenAction.generateResult)
    case .generateResult(let result):
        switch result {
        case .success:
            state.status = .success
        case .failure:
            state.status = .failure
        }
        return .none
    case .quantityChanged(let quantity):
        guard ClosedRange.PHONE_NUMBER_GEN_QUANT.contains(Int(quantity) ?? 0) else { return .none }
        state.quantityToGenerateAsString = quantity
        return .none
    }
}
