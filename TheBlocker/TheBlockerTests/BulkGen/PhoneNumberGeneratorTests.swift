//
//  PhoneNumberGeneratorTests.swift
//  TheBlockerTests
//
//  Created by Andrew Roan on 1/17/21.
//

import XCTest
import Combine
@testable import TheBlocker

class SequentialGen {
    let cyclesToIterate: Int
    var cycles: Int = 0 {
        didSet {
            if cycles >= cyclesToIterate {
                iteration += 1
                cycles = 0
            }
        }
    }
    // swiftlint:disable:next identifier_name
    var _iteration: Int = 0
    var iteration: Int {
        get { _iteration }
        set { _iteration = newValue > max ? min : newValue }
    }
    let min: Int
    let max: Int

    init(cyclesToIterate: Int, iterationRange: ClosedRange<Int>) {
        self.cyclesToIterate = cyclesToIterate
        self.min = iterationRange.min() ?? 0
        self.max = iterationRange.max() ?? 1
        self.iteration = self.min
    }

    func getIteration() -> Int {
        defer {
            cycles += 1
        }
        return iteration
    }
}

class MockPhoneNumberGeneratorRepository {
    typealias Success = Repository.BatchInsert.Success
    typealias Failure = Repository.BatchInsert.Failure
    var insertedPhoneNumbers = Set<Int64>()
    var desiredResult: Result<Success, Failure> = .success(.init())
    func insert(phoneNumbers: Set<Int64>) -> AnyPublisher<Success, Failure> {
        insertedPhoneNumbers = phoneNumbers
        return desiredResult.publisher.eraseToAnyPublisher()
    }
}

extension PhoneNumberGenerator.RepositoryClient {
    static func mock(repo: MockPhoneNumberGeneratorRepository) -> Self {
        Self(insert: repo.insert)
    }
}

class PhoneNumberGeneratorTests: XCTestCase {
    var cancellables = [AnyCancellable]()
    var sequential = SequentialGen(cyclesToIterate: 3, iterationRange: 0...4)
    lazy var generators = PhoneNumberGenerator.Generators(random: { _ in self.sequential.getIteration() })
    let repo = MockPhoneNumberGeneratorRepository()
    lazy var repoClient = PhoneNumberGenerator.RepositoryClient.mock(repo: repo)
    override func setUp() {
        super.setUp()
        repo.insertedPhoneNumbers = .init()
    }

    override func tearDown() {
        super.tearDown()
        repo.insertedPhoneNumbers = .init()
    }

    func testRandomSucccess() {
        let resultExpectation = expectation(description: "\(#function)\(#line) - The result should be successful")
        let expectedData = Set<Int64>([100_000_0000_0, 100_100_1000_1, 100_200_2000_2, 100_300_3000_3, 100_400_4000_4])
        let gen = PhoneNumberGenerator(generators: self.generators, repository: repoClient)
        gen.random(5).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    resultExpectation.fulfill()
                case .failure:
                    assertionFailure("result failure")
                }
            },
            receiveValue: { _ in }
        ).store(in: &self.cancellables)
        waitForExpectations(timeout: 5, handler: nil)
        let insertedData = repo.insertedPhoneNumbers
        assert(insertedData == expectedData, "Resulting data did not match expectation")
    }

    func testRandomOverflowWrapSuccess() {
        let invertedSuccessExpectation = expectation(
            description: "\(#function)\(#line) - Success when expecting failure.")
        invertedSuccessExpectation.isInverted = true
        let failureExpectation = expectation(description: "\(#function)\(#line) - Success when expecting failure.")
        let gen = PhoneNumberGenerator(generators: self.generators, repository: repoClient)
        // Request quantity that will overflow and wrap the generator function.
        // It will never meet the quantity since a Set has all unique values.
        gen.random(10).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    invertedSuccessExpectation.fulfill()
                case .failure:
                    failureExpectation.fulfill()
                }
            },
            receiveValue: { _ in }
        ).store(in: &self.cancellables)
        waitForExpectations(timeout: 5, handler: nil)
        assert(repo.insertedPhoneNumbers.count == 0, "\(#function)\(#line) - data should be empty due to failure")
    }
}
