//
//  Repository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import CoreData
import Combine

final class Repository {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    enum Errors: Hashable, Error {
        case unknown
        case noneMatchingID
        case invalid
    }
}
