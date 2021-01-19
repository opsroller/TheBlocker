//
//  UserDefaultsRepositoryClient.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation
import CoreData

/// Dependency injection adapter for `UserDefaultsRepository`
struct UserDefaultsRepositoryClient {
    let setLastBlockListUpdate: (Date) -> Void
    let getLastBlockListUpdate: () -> Date?
}

extension UserDefaultsRepositoryClient {
    /// The static instance intended for production use.
    static let prod: UserDefaultsRepositoryClient = {
        let repo = UserDefaultsRepository(suite: .group)
        return Self(
            setLastBlockListUpdate: repo.setLastBlockListUpdate,
            getLastBlockListUpdate: repo.getLastBlockListUpdate
        )
    }()
}
