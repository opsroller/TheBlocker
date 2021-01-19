//
//  ModelBridging.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData

protocol RepositoryManagedModel: NSManagedObject, Identifiable {
    associatedtype Unmanaged: UnmanagedModel
        where Unmanaged.RepoManaged == Self, Self.ID == Unmanaged.ID
    static var typeName: String { get }
    var asUnmanaged: Unmanaged { get }
    func update(from unmanaged: Unmanaged)
    static func fetchRequest() -> NSFetchRequest<Self>
}

extension RepositoryManagedModel {
    static var typeName: String {
        String(describing: Self.self)
    }
}

extension RepositoryManagedModel {
    static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: Self.typeName)
    }
}

protocol UnmanagedModel: Identifiable, Hashable {
    associatedtype RepoManaged: RepositoryManagedModel
        where RepoManaged.Unmanaged == Self, Self.ID == RepoManaged.ID
    var repoID: NSManagedObjectID? { get set }
    func asRepoManaged(in context: NSManagedObjectContext) -> RepoManaged
}
