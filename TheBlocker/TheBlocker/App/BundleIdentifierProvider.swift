//
//  BundleInfoProvider.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Convenince entity for accessing bundle id and group id.
struct BundleInfoProvider {
    let bundleId: String
    let groupId: String
}

extension BundleInfoProvider {
    /// Static instance intended for production
    static let prod: Self = Self(
        bundleId: Bundle.main.object(forInfoDictionaryKey: "Bundle identifier") as? String ?? "",
        groupId: Bundle.main.object(forInfoDictionaryKey: "GROUP_ID") as? String ?? ""
    )
}
