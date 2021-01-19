//
//  CallDirectoryHandler.swift
//  CallKitExtension
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation
import CallKit
import os.log

class CallDirectoryHandler: CXCallDirectoryProvider {
    let repo = CallKitRepositoryClient.prod

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        /*
         Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
         and identification entries which have been added or removed since the last time this extension's data was
         loaded. But the extension must still be prepared to provide the full set of data at any time, so add all
         blocking and identification phone numbers if the request is not incremental.
         */
        if let lastUpdated = UserDefaultsRepositoryClient.prod.getLastBlockListUpdate(), context.isIncremental {
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context, after: lastUpdated)
        } else {
            addAllBlockingPhoneNumbers(to: context)
        }

        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        /*
         Retrieve all phone numbers to block from data store. For optimal performance and memory usage
         when there are many phone numbers, consider only loading a subset of numbers at a given time
         and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
         Numbers must be provided in numerically ascending order.
         */
        let allPhoneNumbers = self.repo.fetchAllBlocked()
        for phoneNumber in allPhoneNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(
        to context: CXCallDirectoryExtensionContext,
        after date: Date
    ) {
        /*
         Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and
         memory usage when there are many phone numbers, consider only loading a subset of numbers at a given time
         and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
         */
        let phoneNumbersToAdd: [CXCallDirectoryPhoneNumber] = self.repo.fetchIncrementalBlockedToAdd(date)
        for phoneNumber in phoneNumbersToAdd {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }

        let phoneNumbersToRemove: [CXCallDirectoryPhoneNumber] = self.repo.fetchIncrementalBlockedToRemove(date)
        for phoneNumber in phoneNumbersToRemove {
            context.removeBlockingEntry(withPhoneNumber: phoneNumber)
        }

        // Update lastUpdated date and purge history before then
        let now = Date()
        UserDefaultsRepositoryClient.prod.setLastBlockListUpdate(now)
        self.repo.purgeHistory(now)
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        /*
         An error occurred while adding blocking or identification entries, check the NSError for details.
         For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.

         This may be used to store the error details in a location accessible by the extension's containing app,
         so that the app may be notified about errors which occurred while loading data even if the request to
         load data was initiated by the user in Settings instead of via the app itself.
         */
        #if DEBUG
        print("\(#function)\(#line) - \(error.localizedDescription)")
        #endif
    }

}
