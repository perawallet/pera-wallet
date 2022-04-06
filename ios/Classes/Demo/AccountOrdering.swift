// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AccountOrdering.swift

import Foundation

struct AccountOrdering {
    let sharedDataController: SharedDataController
    let session: Session

    private let watchAccountOrderOffset = 100000

    func getNewAccountIndex(for type: AccountType) -> Int {
        let sortedAccounts = sharedDataController.accountCollection.sorted()

        if type == .watch {
            guard let lastWatchAccount = sortedAccounts.last(where: { $0.value.type == .watch }) else {
                return watchAccountOrderOffset
            }

            return lastWatchAccount.value.preferredOrder + 1
        }

        guard let lastNonWatchAccount = sortedAccounts.last(where: { !$0.value.isWatchAccount() }) else {
            return 0
        }

        return lastNonWatchAccount.value.preferredOrder + 1
    }

    func reorder(_ accounts: [AccountHandle], with type: AccountType) {
        for (index, account) in accounts.enumerated() {
            let newAccountOrder = type == .watch ? index + watchAccountOrderOffset : index
            sharedDataController.accountCollection[account.value.address]?.value.preferredOrder = newAccountOrder
            account.value.preferredOrder = newAccountOrder
            session.authenticatedUser?.updateLocalAccount(account.value)
        }
    }
}
