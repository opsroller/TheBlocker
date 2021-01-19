//
//  PhoneNumberListReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import Foundation
import ComposableArchitecture

/// Feature for displaying a list of phone numbers, deleting numers from the list, and supports infinite scrolling
let phoneNumberListReducer = Reducer<PhoneNumberListState, PhoneNumberListAction, PhoneNumberListEnv>.combine(
    // Supports deleting phone numbers from the list
    phoneNumberCRUDReducer.pullback(
        state: \PhoneNumberListState.crudRepo,
        action: /PhoneNumberListAction.crudRepo,
        environment: { CRUDRepositoryEnv<PhoneNumber>.init(phoneNumberList: $0) }),
    // Supports fetching phone numbers from persistent storage
    phoneNumberFetchReducer.pullback(
        state: \PhoneNumberListState.fetchRepo,
        action: /PhoneNumberListAction.fetchRepo,
        environment: { FetchRepositoryEnv<PhoneNumber>.init(phoneNumberList: $0) }
    ),
    // Supports getting total count value of the list
    phoneNumberAggregateReducer.pullback(
        state: \PhoneNumberListState.aggregateRepo,
        action: /PhoneNumberListAction.aggregateRepo,
        environment: { AggregateRepositoryEnv(phoneNumberList: $0) }
    ),
    Reducer { state, action, _ in
        switch action {
        case .addNewNumber(let phoneNumberToAdd):
            return .none
        case .isAddNewPresented(let isPresented):
            return .none
        case .newNumberChanged(let newPhoneNumber):
            return .none
        case .removeNumber(let phoneNumberToRemove):
            guard let repoID = phoneNumberToRemove.repoID else { return .none }
            return Effect(value: PhoneNumberListAction.crudRepo(.delete(repoID, phoneNumberToRemove.asCXPhoneNumber)))
        case .removeNumbers(let phoneNumbersToRemove):
            let effects = phoneNumbersToRemove.map { phoneNumber in
                Effect<PhoneNumberListAction, Never>(value: PhoneNumberListAction.removeNumber(phoneNumber))
            }
            return .merge(effects)
        case .fetch:
            return .merge(
                Effect(value: PhoneNumberListAction
                    .fetchRepo(.fetch(state.fetchRepo.fetchRequest(predicate: state.predicate, sortDesc: state.sort)))),
                Effect(value: PhoneNumberListAction
                    .aggregateRepo(.count(state.aggregateRepo.fetchRequest(predicate: state.predicate))))
            )
        case .crudRepo(let crudRepoAction):
            switch crudRepoAction {
            case .repoResult(let result):
                switch result {
                case let .success(.delete(id)):
                    state.fetchRepo.items.removeAll(where: { $0.id == id })
                    return Effect(value: PhoneNumberListAction
                                    .aggregateRepo(.count(state.aggregateRepo.fetchRequest(predicate: state.predicate))))
                default:
                    return .none
                }
            default:
                return .none
            }
        default:
            return .none
        }
    }
)

// Concrete instances from generic reducer factory
let phoneNumberFetchReducer: Reducer<
    FetchRepositoryState<PhoneNumber>,
    FetchRepositoryAction<PhoneNumber>,
    FetchRepositoryEnv<PhoneNumber>
> = Reducer<Any, Any, Any>.fetchRepository()

let phoneNumberAggregateReducer: Reducer<
    AggregateRepositoryState<PhoneNumber>,
    AggregateRepositoryAction<PhoneNumber>,
    AggregateRepositoryEnv<PhoneNumber>
> = Reducer<Any, Any, Any>.aggregateRepository()
