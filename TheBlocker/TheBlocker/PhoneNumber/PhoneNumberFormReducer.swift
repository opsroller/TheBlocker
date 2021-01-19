//
//  PhoneNumberFormReducer.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/16/21.
//

import ComposableArchitecture

// Feature for adding a blocked or allowed phone number
let phoneNumberFormReducer = Reducer<PhoneNumberFormState, PhoneNumberFormAction, PhoneNumberFormEnv>.combine(
    // Supports adding the valid phone number
    phoneNumberCRUDReducer.pullback(
        state: \PhoneNumberFormState.repo,
        action: /PhoneNumberFormAction.repo,
        environment: { CRUDRepositoryEnv(phoneNumberForm: $0) }
    ),
    Reducer { state, action, env in
        switch action {
        case .inputChanged(let input):
            guard PhoneNumber.isIncompleteButValid(input) else { return .none }
            state.isValid = PhoneNumber.isValid(input) && input.count <= 10
            state.userInput = input
            return .none
        case .submitted:
            guard let phoneNumber = PhoneNumber(
                    "1" + state.userInput,
                    isBlocked: state.isBlocked,
                    created: env.date()) else { return .none }
            state.userInput = ""
            return Effect(value: PhoneNumberFormAction.repo(.create(phoneNumber)))
        case .repo:
            return .none
        case .changedIsBlocked(let isBlocked):
            state.isBlocked = isBlocked
            return .none
        }
    }
)

let phoneNumberCRUDReducer: Reducer<
    CRUDRepositoryState,
    CRUDRepositoryAction<PhoneNumber>,
    CRUDRepositoryEnv<PhoneNumber>
> = Reducer<Any, Any, Any>.crudRepository()

/*
extension Reducer where State == Void {
    func pullback<
 GlobalState,
 GlobalAction,
 GlobalEnvironment
 >(
 action toLocalAction: CasePath<GlobalAction, Action>,
 environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
 ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
        .init { _, globalAction, globalEnvironment in
            guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
            return self.reducer(Void, localAction, toLocalEnvironment(globalEnvironment))
        }
    }
}
*/
