//
//  PhoneNumberListCellView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/18/21.
//

import SwiftUI

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
struct PhoneNumberListCellView: View {
    let phoneNumber: PhoneNumber
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        return formatter
    }()

    var body: some View {
        HStack {
            // MARK: Text view of phone number
            Text(phoneNumber.asString)
                .padding(.leading)
            Spacer()
            // MARK: Created and lastModified dates (in relative format)
            VStack {
                if let created = phoneNumber.created {
                    Text(String("created: \(self.dateFormatter.string(from: created))"))
                        .font(.caption)
                }
                if let lastModified = phoneNumber.lastModified {
                    Text(String("updated: \(self.dateFormatter.string(from: lastModified))"))
                        .font(.caption)
                }
            }
            .padding(.trailing)
        }
    }
}
