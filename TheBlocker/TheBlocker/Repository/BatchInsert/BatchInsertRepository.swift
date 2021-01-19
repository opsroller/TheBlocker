//
//  BatchInsertRepository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import Combine

protocol BatchInsertable: RepositoryManagedModel {
    associatedtype PayloadSeed
    static func insertablePayload(_ seed: PayloadSeed) -> ((NSManagedObject) -> Bool)
}

extension Repository {
    final class BatchInsert {
        // should always be a background context
        let context: NSManagedObjectContext

        init(context: NSManagedObjectContext) {
            self.context = context
        }
    }
}

extension Repository.BatchInsert {
    struct Success: Equatable {}

    enum Failure: Error, Equatable {
        case unknown
    }

    func insert(_ data: [[String: Any]], for entityName: String) -> AnyPublisher<Success, Failure> {
        Deferred { Future { [weak self] callback in
            guard let self = self else { return callback(.failure(.unknown)) }
            self.context.performAndWait { [weak self] in
                guard let self = self else { return callback(.failure(.unknown)) }
                let batchInsertRequest = NSBatchInsertRequest(entityName: entityName, objects: data)
                if let batchInsertResult = try? self.context.execute(batchInsertRequest) as? NSBatchInsertResult,
                    let success = batchInsertResult.result as? Bool,
                    success {
                    return callback(.success(Success()))
                }
            }
        }}.eraseToAnyPublisher()
    }
}
