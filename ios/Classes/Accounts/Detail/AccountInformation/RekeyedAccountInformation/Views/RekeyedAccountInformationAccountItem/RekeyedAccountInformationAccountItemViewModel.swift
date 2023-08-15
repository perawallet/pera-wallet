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

//   RekeyedAccountInformationAccountItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct RekeyedAccountInformationAccountItemViewModel: ViewModel {
    private(set) var sourceAccount: AccountListItemWithActionViewModel?
    private(set) var authAccount: AccountListItemWithActionViewModel?

    init(
        sourceAccount: Account,
        authAccount: Account?
    ) {
        bindSourceAccount(sourceAccount)
        bindAuthAccount(sourceAccount: sourceAccount, authAccount: authAccount)
    }
}

extension RekeyedAccountInformationAccountItemViewModel {
    private mutating func bindSourceAccount(_ sourceAccount: Account) {
        self.sourceAccount = AccountInformationCopyAccountItemViewModel(sourceAccount)
    }

    private mutating func bindAuthAccount(sourceAccount: Account, authAccount: Account?) {
        if let authAccount {
            self.authAccount = AccountInformationUndoRekeyAccountItemViewModel(authAccount)
        } else {
            let authAddress = sourceAccount.authAddress.someString
            self.authAccount = AccountInformationNoAuthAccountItemViewModel(authAddress)
        }
    }
}
