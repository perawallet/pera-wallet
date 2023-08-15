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

//   RemoveAuthAccountAuthorizationValidator.swift

import Foundation

final class RemoveAuthAccountAuthorizationValidator: RemoveAccountAuthorizationValidator {
    var nextValidator: RemoveAccountAuthorizationValidator?

    private let sharedDataController: SharedDataController

    init(sharedDataContoller: SharedDataController) {
        self.sharedDataController = sharedDataContoller
    }

    func validate(_ account: Account) -> RemoveAccountAuthorizationResult {
        if account.authorization.isWatch {
            return validateNextIfPossible(account)
        }

        let rekeyedAccounts = getRekeyedAccounts(of: account)

        let hasAnyRekeyedAccounts = rekeyedAccounts.isNonEmpty
        if hasAnyRekeyedAccounts {
            let error = RemoveAuthAccountAuthorizationError(rekeyedAccounts: rekeyedAccounts)
            return .denied(error)
        }

        return validateNextIfPossible(account)
    }

    private func getRekeyedAccounts(of account: Account) -> [AccountHandle] {
        return sharedDataController.rekeyedAccounts(of: account)
    }
}

struct RemoveAuthAccountAuthorizationError: RemoveAccountErrorDisplayable {
    private(set) var message: String

    init(rekeyedAccounts: [AccountHandle]) {
        message =
            rekeyedAccounts.isSingular
            ? "remove-auth-account-rekeyed-account-error-title".localized
            : "remove-auth-account-rekeyed-accounts-error-title".localized(params: "\(rekeyedAccounts.count)")
    }
}
