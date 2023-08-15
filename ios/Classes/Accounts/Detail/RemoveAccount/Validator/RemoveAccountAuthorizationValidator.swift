// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RemoveAccountAuthorizationValidator.swift

import Foundation

protocol RemoveAccountAuthorizationValidator: AnyObject {
    var nextValidator: RemoveAccountAuthorizationValidator? { get set }
    func validate(_ account: Account) -> RemoveAccountAuthorizationResult
}

extension RemoveAccountAuthorizationValidator {
    func setNext(_ validator: RemoveAccountAuthorizationValidator) -> RemoveAccountAuthorizationValidator {
        nextValidator = validator
        return validator
    }

    func validateNextIfPossible(_ account: Account) -> RemoveAccountAuthorizationResult {
        nextValidator?.validate(account) ?? .granted
    }
}

protocol RemoveAccountErrorDisplayable {
    var message: String { get }
}

enum RemoveAccountAuthorizationResult {
    case granted
    case denied(RemoveAccountErrorDisplayable)
}
