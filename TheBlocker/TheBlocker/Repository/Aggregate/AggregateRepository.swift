//
//  AggregateRepository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import CoreData
import Combine

extension Repository {
    final class Aggregate {
        let context: NSManagedObjectContext

        init(context: NSManagedObjectContext) {
            self.context = context
        }
    }
}

extension Repository.Aggregate {
    typealias Errors = Repository.Errors

    enum Success: Hashable {
        case count(Int)
    }

    enum Failure<Model: UnmanagedModel>: Hashable, Error {
        case count(FetchRequest<Model>, Errors)
    }

    func count<Model: UnmanagedModel>(_ request: FetchRequest<Model>) -> Future<Success, Failure<Model>> {
        Future { [weak self] callback in
            guard let self = self else {
                return callback(.failure(.count(request, .unknown)))
            }
            self.context.perform {
                do {
                    let count = try self.context.count(for: request.nsFetchRequest)
                    callback(.success(.count(count)))
                } catch {
                    #if DEBUG
                        print("###\(#function): \(error.localizedDescription)")
                    #endif
                    callback(.failure(.count(request, .unknown)))
                }
            }
        }
    }
}
