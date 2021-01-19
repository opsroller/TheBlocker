//
//  PhoneNumberListAction.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/15/21.
//

import Foundation

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
enum PhoneNumberListAction: Equatable {
    case addNewNumber(PhoneNumber)
    case newNumberChanged(PhoneNumber)
    case removeNumber(PhoneNumber)
    case removeNumbers([PhoneNumber])
    case isAddNewPresented(Bool)
    case fetchRepo(FetchRepositoryAction<PhoneNumber>)
    case crudRepo(CRUDRepositoryAction<PhoneNumber>)
    case aggregateRepo(AggregateRepositoryAction<PhoneNumber>)
    case fetch
}
