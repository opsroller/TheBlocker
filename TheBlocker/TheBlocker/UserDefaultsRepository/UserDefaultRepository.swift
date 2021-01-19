//
//  UserDefaultRepository.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import Foundation
import CoreData

extension UserDefaults {
    /// A UserDefaults suite for the app's group container.
    static let group: UserDefaults = UserDefaults(suiteName: BundleInfoProvider.prod.groupId)!
}

/// A repository for interacting with UserDefaults
final class UserDefaultsRepository {
    let suite: UserDefaults

    init(suite: UserDefaults = .group) {
        self.suite = suite
    }

    /// Sets a new date value for when the CallKit extension block list was last updated.
    /// It supports incremental updates by only fetching persistence changes after this date.
    ///
    /// - Parameters:
    ///     - date: The `Date` value to set
    func setLastBlockListUpdate(_ date: Date) {
        guard let data = try? JSONEncoder().encode(date) else { return }
        self.suite.set(data, forKey: DefaultName.lastBlockListUpdate.rawValue)
    }

    /// Sets a new date value for when the CallKit extension block list was last updated.
    /// It supports incremental updates by only fetching persistence changes after this date.
    /// - Returns:
    ///     - `Date?`
    func getLastBlockListUpdate() -> Date? {
        guard let data = self.suite.data(forKey: DefaultName.lastBlockListUpdate.rawValue),
              let date = try? JSONDecoder().decode(Date.self, from: data) else { return nil }
        return date
    }
}
