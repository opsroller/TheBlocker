//
//  PhoneNumberGenerator.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Foundation
import Combine

// MARK: Phone number component ranges
extension ClosedRange where Bound == Int {
    // swiftlint:disable identifier_name
    /// Constant defining the range of area codes in the US numbering system.
    static let AREA_CODE = 200...999
    /// Constant defining the range of central office codes in the US numbering system.
    static let CENTRAL_OFFICE_CODE = 200...999
    /// Constant defining the range of line numbers in the US numbering system.
    static let LINE_NUMBER = 0...9999
}

// MARK: Phone number component powers/multipliers
extension Int {
    /// Constant defining the power of a country code in a phone number. App currently assuming only US numbers.
    static let COUNTRY_CODE = 1_000_000_0000
    /// Constant defining the power of an area code in a phone number.
    static let AREA_CODE_MULT = 1_000_0000
    /// Constant defining the power of a central office code in a phone number.
    static let CENTRAL_OFFICE_CODE_MULT = 1_0000
    /// For consistency, a constant defining the power of a line number in a phone number.
    static let LINE_NUMBER_MULT = 1
}

// MARK: PhoneNumberGenerator
/// Generates large quantities of phone numbers.
final class PhoneNumberGenerator {
    /// Alias of the function signature used for different patterns of generating numbers
    /// - Parameters
    ///     - `ClosedRange<Int>`
    /// - Returns
    ///     - `Int`
    typealias Generator = (ClosedRange<Int>) -> Int

    // MARK: Private Properties
    private let generators: Generators
    private let repository: RepositoryClient
    private var cancellables = [AnyCancellable]()
    /// Tracks the number of times the recursion loops to ensure escaping if stuck
    private var escapeHatchCounter = 0
    /// Defines the threshold of `escapeHatchCounter` to trigger an escape
    private let escapeHatchThreshold = 5

    // MARK: init
    init(generators: Generators, repository: RepositoryClient) {
        self.generators = generators
        self.repository = repository
    }

    // MARK: Private Methods
    /// Used to break out of recursion if it loops beyond the threshold: `escapeHatchThreshold`
    private func escape() -> Bool {
        self.escapeHatchCounter += 1
        if self.escapeHatchCounter > escapeHatchThreshold {
            return true
        }
        return false
    }

    /// Creates a single phone number defined by the `Generator`  from the components .
    /// - Parameters
    ///     - `with generator: Generator`
    /// - Returns
    ///     - `Int64` (Phone Number)
    private func assemble(with generator: Generator) -> Int64 {
        let areaCode = generator(.AREA_CODE)
        let centralOfficeCode = generator(.CENTRAL_OFFICE_CODE)
        let lineNumber = generator(.LINE_NUMBER)
        return Int64(
            Int.COUNTRY_CODE
                + (areaCode*Int.AREA_CODE_MULT)
                + (centralOfficeCode*Int.CENTRAL_OFFICE_CODE_MULT)
                + (lineNumber*Int.LINE_NUMBER_MULT)
        )
    }
    // ****** DANGER ******* Mutual recursion or unbounded loop starts here
    // TODO: Change to while loop from recursion
    /*
     Since every phone number is unique, a set is used to ensure no duplicates. As such,
     It's very possible that when generating numbers that duplicates could be formed and then
     dropped. Quantity is checked after every run of `assemblyLine` and then looped back if
     below `quantity` or truncate `quantity` if there are too many. There should never be too many
     but it feels good to have that branch handled anyway.
     */

    /// Calls for `assemble` for each step in quantity.
    /// - Parameters
    ///     - `quantity: Int`
    ///     - `with generator: Generator`
    /// - Returns
    ///     - `Set<Int64`
    private func assemblyLine(_ quantity: Int, with generator: Generator) -> Set<Int64> {
        // Working with a known, large number of elements. Be sure to reserve space for efficiency.
        var result: Set<Int64> = .init(minimumCapacity: quantity)
        (0..<quantity).forEach { _ in result.insert(assemble(with: generator)) }
        return checkQuantity(quantity: quantity, result: result, generator: generator)
    }

    /// Verifies that the result of `assemblyLine` matches the request. If not, it either calls back to `assemblyLine` or truncates.
    /// - Parameters
    ///     - `quantity: Int`
    ///     - `result: Set<Int64>`
    ///     - `generator: Generator`
    /// - Returns
    ///     - `Set<Int64>`
    private func checkQuantity(quantity: Int, result: Set<Int64>, generator: Generator) -> Set<Int64> {
        let diff: Int = quantity - result.count
        if diff == 0 {
            return result
        } else if diff > 0 {
            // Check if the escape threshold is met!!
            guard !escape() else { return result }
            return checkQuantity(
                quantity: quantity,
                result: result.union(assemblyLine(diff, with: generator)),
                generator: generator
            )
        } else {
            return Set(result.dropLast(diff))
        }
    }
    // ****** End DANGER *******

    /// Sends the resulting set of values to persistant storage
    /// - Parameters
    ///     - `quantity: Int`
    ///     - `with generator @escaping Generator`
    /// - Returns
    ///     - `AnyPublisher<Success, Failure>`
    private func deliverToRepository(
        quantity: Int,
        with generator: @escaping Generator
    ) -> AnyPublisher<Success, Failure> {
        Deferred { Future { [weak self] callback in
            // Use a weak reference to self since it's an async closure
            guard let self = self else { return callback(.failure(.unknown)) }
            let genResult = self.assemblyLine(quantity, with: generator)
            guard genResult.count == quantity else {
                return callback(.failure(.escapedInfiniteRecursion(resultQuantitiy: genResult.count)))
            }
            self.repository.insert(genResult).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        callback(.success(Success()))
                    case .failure(let failure):
                        callback(.failure(Failure(failure)))
                    }
                },
                receiveValue: { _ in callback(.success(Success())) }
            ).store(in: &self.cancellables)
        }}.eraseToAnyPublisher()
    }

    // MARK: Methods
    /// Public endpoint for random generation calls
    /// - Parameters
    ///     - `quantity: Int`
    /// - Returns
    ///     - `AnyPublisher<Success, Failure>`
    func random(quantity: Int) -> AnyPublisher<Success, Failure> {
        self.deliverToRepository(quantity: quantity, with: self.generators.random)
    }

    struct Success: Equatable {}

    enum Failure: Error, Equatable {
        /// Maps repository errors to bulk generator domain
        case batchInsert(Repository.BatchInsert.Failure)
        case unknown
        /// Signals that the recursion threshold was met. Probably means that the input parameters aren't valid.
        case escapedInfiniteRecursion(resultQuantitiy: Int)

        init(_ error: Error) {
            if let batchInsertError = error as? Repository.BatchInsert.Failure {
                self = .batchInsert(batchInsertError)
            } else {
                self = .unknown
            }
        }
    }

    struct Generators {
        let random: (ClosedRange<Int>) -> Int
        // TODO: Add more realistic generators like sequential, pattern matching, etc
    }
}

// MARK: Production instance
extension PhoneNumberGenerator {
    static func prod(generators: Generators = .prod, repository: RepositoryClient) -> Self {
        Self(generators: generators, repository: repository)
    }
}

// MARK: Production instances of Generators
extension PhoneNumberGenerator.Generators {
    static let prod = Self(random: Int.random)
}
