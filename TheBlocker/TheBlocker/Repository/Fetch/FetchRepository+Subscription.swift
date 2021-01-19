//
//  FetchRepository+Subscription.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import Combine

protocol FetchSubscription {
    var id: AnyHashable { get }
    func manualFetch()
    func cancel()
}

extension Repository.Fetch {

    class SubscriptionProvider<Model: UnmanagedModel>: NSObject, NSFetchedResultsControllerDelegate {
        private let request: FetchRequest<Model>
        private let frc: NSFetchedResultsController<Model.RepoManaged>
        let subject: PassthroughSubject<Success<Model>, Failure<Model>> = .init()

        init(request: FetchRequest<Model>, context: NSManagedObjectContext) {
            self.request = request
            self.frc = NSFetchedResultsController(
                fetchRequest: request.nsFetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            self.frc.delegate = self
        }

        private func fetch() {
            self.frc.managedObjectContext.perform {
                let items = (self.frc.fetchedObjects ?? []).map { $0.asUnmanaged }
                self.subject.send(.fetchSubscribe(FetchResponse(items, request: self.request)))
            }
        }

        // NSFetchedResultsControllerDelegate conformance
        internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.fetch()
        }

        func manualFetch() {
            self.fetch()
        }

        func cancel() {
            self.subject.send(completion: .finished)
        }

        func fail(_ failure: Failure<Model>) {
            self.subject.send(completion: .failure(failure))
        }
    }
}

extension Repository.Fetch.SubscriptionProvider: FetchSubscription {}

extension Repository.Fetch.SubscriptionProvider: Identifiable {
    var id: AnyHashable { request.id }
}
