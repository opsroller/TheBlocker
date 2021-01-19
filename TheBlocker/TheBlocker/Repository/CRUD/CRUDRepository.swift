//
//  CRUDRepository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import Combine

extension Repository {
    final class CRUD {
        let context: NSManagedObjectContext

        init(context: NSManagedObjectContext) {
            self.context = context
        }
    }
}

extension Repository.CRUD {
    typealias Errors = Repository.Errors
    enum Success<Model: UnmanagedModel>: Hashable {
        case create(Model.ID)
        case read(Model)
        case update(Model.ID)
        case delete(Model.ID)
    }

    enum Failure<Model: UnmanagedModel>: Hashable, Error {
        case create(Model.ID, Errors)
        case read(Model.ID, Errors)
        case update(Model.ID, Errors)
        case delete(Model.ID, Errors)
    }

    func create<Model: UnmanagedModel>(_ item: Model) -> Result<Success<Model>, Failure<Model>> {
        var result: Result<Success<Model>, Failure<Model>> = .failure(.create(item.id, .unknown))
        let editContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        editContext.parent = self.context
        editContext.performAndWait { [editContext] () -> Void in
            let object = Model.RepoManaged(context: editContext)
            object.update(from: item)
            do {
                editContext.transactionAuthor = "CRUD.create"
                try editContext.save()
                result = .success(.create(item.id))
            } catch {
                result = .failure(Failure.create(item.id, .invalid))
                #if DEBUG
                    print("###\(#function): \(error.localizedDescription)")
                #endif
            }
        }
        if result == .success(.create(item.id)) {
            self.context.performAndWait {
                do {
                    try self.context.save()
                } catch {
                    result = .failure(Failure.create(item.id, .unknown))
                    #if DEBUG
                        print("###\(#function): \(error.localizedDescription)")
                    #endif
                }
            }
        }
        return result
    }

    func read<Model: UnmanagedModel>(
        _ objectID: NSManagedObjectID,
        id: Model.ID
    ) -> Result<Success<Model>, Failure<Model>> {
        var result: Result<Success<Model>, Failure<Model>> = .failure(.read(id, .unknown))
        context.performAndWait { [context] () -> Void in
            guard let object: Model.RepoManaged = fetchModel(objectID: objectID, id: id, context: context) else {
                result = .failure(Failure.read(id, .noneMatchingID))
                return
            }
            result = .success(.read(object.asUnmanaged))
        }
        return result
    }

    func fetchModel<RepoModel: RepositoryManagedModel>(
        objectID: NSManagedObjectID, id: RepoModel.ID, context: NSManagedObjectContext) -> RepoModel? {
        guard let item: RepoModel = existingObject(objectID, context: context) else {
            return fetchByID(id, context: context)
        }
        return item
    }

    func existingObject<RepoModel: RepositoryManagedModel>(
        _ id: NSManagedObjectID,
        context: NSManagedObjectContext
    ) -> RepoModel? {
        do {
            return try (context.existingObject(with: id) as? RepoModel)
        } catch {
            #if DEBUG
                print("###\(#function): \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func fetchByID<RepoModel: RepositoryManagedModel>(
        _ id: RepoModel.ID,
        context: NSManagedObjectContext
    ) -> RepoModel? {
        do {
            let fetchRequest = NSFetchRequest<RepoModel>(entityName: RepoModel.typeName)
            fetchRequest.predicate = NSComparisonPredicate(
                leftExpression: NSExpression(forKeyPath: \RepoModel.id),
                rightExpression: NSExpression(forConstantValue: id),
                modifier: .direct,
                type: .equalTo,
                options: .normalized
            )
            let results = try self.context.fetch(fetchRequest)
            return results.first
        } catch {
            #if DEBUG
                print("###\(#function): \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func update<Model: UnmanagedModel>(
        _ item: Model,
        objectID: NSManagedObjectID
    ) -> Result<Success<Model>, Failure<Model>> {
        var result = Result<Success<Model>, Failure<Model>>.success(.update(item.id))
        context.performAndWait { [context] () -> Void in
            guard let object: Model.RepoManaged = fetchModel(objectID: objectID, id: item.id, context: context) else {
                return
            }
            object.update(from: item)
            do {
                context.transactionAuthor = "CRUD.update"
                try context.save()
                result = .success(.update(item.id))
            } catch {
                #if DEBUG
                    print("###\(#function): \(error.localizedDescription)")
                #endif
                return
            }
        }
        return result
    }

    func delete<Model: UnmanagedModel>(
        _ objectID: NSManagedObjectID,
        id: Model.ID
    ) -> Result<Success<Model>, Failure<Model>> {
        var result: Result<Success<Model>, Failure<Model>> = .failure(.delete(id, .unknown))
        context.performAndWait { [context] () -> Void in
            do {
                guard let object: Model.RepoManaged = fetchModel(
                        objectID: objectID,
                        id: id,
                        context: context
                ) else { return }
                context.delete(object)
                context.transactionAuthor = "CRUD.delete"
                try context.save()
                result = .success(.delete(id))
            } catch {
                result = .failure(.delete(id, .unknown))
            }
        }
        return result
    }
}
