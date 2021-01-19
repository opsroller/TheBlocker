//
//  FetchRequest.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Foundation

struct FetchRequest<Model: UnmanagedModel>: Hashable {
    let id: AnyHashable
    var offset: Int = 0
    var limit: Int = 0
    var predicate: NSPredicate = .init(value: true)
    var sortDesc: [NSSortDescriptor] = []
}
