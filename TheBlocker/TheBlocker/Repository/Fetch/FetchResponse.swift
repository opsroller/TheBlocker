//
//  FetchResponse.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import Foundation

struct FetchResponse<Model: UnmanagedModel>: Hashable {
    let id: AnyHashable
    let data: [Model]
    let offset: Int
    let limit: Int
}

extension FetchResponse {
    init(_ data: [Model], request: FetchRequest<Model>) {
        self.id = request.id
        self.data = data
        self.offset = request.offset
        self.limit = request.limit
    }
}
