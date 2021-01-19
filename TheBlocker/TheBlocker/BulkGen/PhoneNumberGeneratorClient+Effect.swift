//
//  PhoneNumberGeneratorClient+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import ComposableArchitecture

/// Dependency injection adapter for `PhoneNumberGenerator` with ComposableArchitecture.Effect masking
struct PhoneNumberGeneratorClientEffect {
    /// Public endpoint for random generation calls
    /// - Parameters
    ///     - `Int`
    /// - Returns
    ///     - `Effect<Success, Failure>`
    let random: (Int) -> Effect<PhoneNumberGenerator.Success, PhoneNumberGenerator.Failure>
}

// MARK: Production instance
extension PhoneNumberGeneratorClientEffect {
    /// Static instance for production
    static func prod(generator: PhoneNumberGenerator) -> Self {
        Self(random: generator.random)
    }
}
