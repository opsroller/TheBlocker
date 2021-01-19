//
//  FetchRepository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import Combine

extension FetchRequest {
    var nsFetchRequest: NSFetchRequest<Model.RepoManaged> {
        let fetchRequest: NSFetchRequest<Model.RepoManaged> = Model.RepoManaged.fetchRequest()
        fetchRequest.sortDescriptors = sortDesc
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset
        return fetchRequest
    }
}

extension Repository {
    final class Fetch {
        let context: NSManagedObjectContext
        var subscriptions = [FetchSubscription]()
        var cancellables = [AnyCancellable]()

        init(context: NSManagedObjectContext) {
            self.context = context
        }

        deinit {
            self.cancellables.forEach { $0.cancel() }
        }
    }
}

extension Repository.Fetch {
    typealias Errors = Repository.Errors

    enum Success<Model: UnmanagedModel>: Hashable {
        case fetch(FetchResponse<Model>)
        case fetchSubscribe(FetchResponse<Model>)
    }

    enum Failure<Model: UnmanagedModel>: Hashable, Error {
        case fetch(FetchRequest<Model>, Errors)
        case fetchSubscribe(FetchRequest<Model>, Errors)
    }

    private func fetch<Model: UnmanagedModel>(_ request: FetchRequest<Model>) -> Result<[Model], Error> {
        Result { [weak self] in
            guard let self = self else { return [] }
            return try self.context.fetch(request.nsFetchRequest).map { $0.asUnmanaged }
        }
    }

    func fetch<Model: UnmanagedModel>(_ request: FetchRequest<Model>) -> Future<Success<Model>, Failure<Model>> {
        Future { [weak self] callback in
            guard let self = self else {
                return callback(.failure(.fetch(request, .unknown)))
            }
            self.context.perform {
                do {
                    let items = try self.context.fetch(request.nsFetchRequest).map { $0.asUnmanaged }
                    callback(.success(.fetch(FetchResponse(items, request: request))))
                } catch {
                    #if DEBUG
                        print("###\(#function): \(error.localizedDescription)")
                    #endif
                    callback(.failure(.fetch(request, .unknown)))
                }
            }
        }
    }

    func fetchSubscribed<Model: UnmanagedModel>(
        _ request: FetchRequest<Model>
    ) -> PassthroughSubject<Success<Model>, Failure<Model>> {
        let subscription = SubscriptionProvider<Model>(request: request, context: self.context)
        self.subscriptions.append(subscription)
        subscription.manualFetch()
        return subscription.subject
    }
}
