//
//  FetchRepository+Effect.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import CoreData
import Combine
import ComposableArchitecture

extension Repository.Fetch {
    func fetch<Model: UnmanagedModel>(_ request: FetchRequest<Model>) -> Effect<Success<Model>, Failure<Model>> {
        Effect.future { [weak self] callback in
            guard let self = self else {
                return callback(.failure(.fetch(request, .unknown)))
            }
            self.context.perform {
                do {
                    let items = try self.context.fetch(request.nsFetchRequest).map { $0.asUnmanaged }
                    callback(.success(.fetch(FetchResponse(items, request: request))))
                } catch {
                    callback(.failure(.fetch(request, .unknown)))
                }
            }
        }
    }

    func fetchSubscribed<Model: UnmanagedModel>(
        _ request: FetchRequest<Model>
    ) -> Effect<Success<Model>, Failure<Model>> {
        Effect.run { [weak self] effectSubscriber -> AnyCancellable in
            guard let self = self else {
                effectSubscriber.send(completion: .failure(.fetchSubscribe(request, .unknown)))
                return AnyCancellable {}
            }
            let subscription = SubscriptionEffectProvider<Model>(
                request: request,
                context: self.context,
                effectSubscriber: effectSubscriber
            )
            self.subscriptions.append(subscription)
            subscription.manualFetch()
            return AnyCancellable {
                subscription.subject.send(completion: .finished)
                self.subscriptions.removeAll(where: { $0.id == subscription.id })
            }
        }
    }
}

extension Repository.Fetch {
    final class SubscriptionEffectProvider<Model: UnmanagedModel>: SubscriptionProvider<Model> {
        private var effectCancellable: AnyCancellable?

        init(
            request: FetchRequest<Model>,
            context: NSManagedObjectContext,
            effectSubscriber: Effect<Success<Model>, Failure<Model>>.Subscriber
        ) {
            super.init(request: request, context: context)
            self.effectCancellable = self.subject.sink(
                receiveCompletion: { completion in effectSubscriber.send(completion: completion) },
                receiveValue: { effectSubscriber.send($0) }
            )
        }
    }
}
