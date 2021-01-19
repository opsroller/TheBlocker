//
//  PhoneNumberGenerator+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Combine
import ComposableArchitecture

extension PhoneNumberGenerator {
    /// ComposableArchitecture.Effect conversion of random
    func random(_ quantity: Int) -> Effect<Success, Failure> {
        let result: AnyPublisher<Success, Failure> = self.random(quantity: quantity)
        return result.eraseToEffect()
    }
}
