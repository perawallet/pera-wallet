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
//   LedgerAccountVerificationDataController.swift

import UIKit

final class LedgerAccountVerificationDataController {
    private let selectedAccounts: [Account]
    private(set) var displayedVerificationAccounts: [Account] = []
    private var verifiedAccounts: [Account] = []
    private var nondisplayedAccounts: [Account] = []

    init(accounts: [Account]) {
        self.selectedAccounts = accounts
        composeVerificationAccounts()
    }
}

extension LedgerAccountVerificationDataController {
    private func composeVerificationAccounts() {
        selectedAccounts.forEach { selectedAccount in
            // Do not display rekeyed accounts if it's auth account is already in the account list
            if selectedAccount.authorization.isRekeyed {
                addSelectedRekeyedAccountIfNeeded(selectedAccount)
                return
            }

            addSelectedAccountIfNeeded(selectedAccount)
        }
    }

    private func addSelectedRekeyedAccountIfNeeded(_ selectedAccount: Account) {
        if shouldDisplaySelectedRekeyedAccount(selectedAccount) {
            displayedVerificationAccounts.append(selectedAccount)
        } else {
            nondisplayedAccounts.append(selectedAccount)
        }
    }

    private func shouldDisplaySelectedRekeyedAccount(_ selectedAccount: Account) -> Bool {
        return !containsSameVerificationAccount(for: selectedAccount) && !containsAuthAccount(for: selectedAccount)
    }

    private func containsAuthAccount(for selectedAccount: Account) -> Bool {
        return selectedAccounts.contains { account -> Bool in
            account.address == selectedAccount.authAddress
        }
    }

    private func containsSameVerificationAccount(for selectedAccount: Account) -> Bool {
        return displayedVerificationAccounts.contains { account -> Bool in
            account.address == selectedAccount.address || account.authAddress == selectedAccount.authAddress
        }
    }

    private func addSelectedAccountIfNeeded(_ selectedAccount: Account) {
        if !displayedVerificationAccounts.contains(selectedAccount) {
            displayedVerificationAccounts.append(selectedAccount)
        }
    }
}

extension LedgerAccountVerificationDataController {
    func isLastAccount(_ account: Account?) -> Bool {
        return displayedVerificationAccounts.last == account
    }

    func nextIndexForVerification(from address: String) -> Int? {
        guard let addressIndex = displayedVerificationAccounts.map({ $0.address }).firstIndex(of: address) else {
            return nil
        }

        return addressIndex + 1
    }

    func addVerifiedAccount(_ address: String?) {
        let verificationAccount = displayedVerificationAccounts.first { $0.address == address }

        if let account = verificationAccount {
            verifiedAccounts.append(account)
            verifiedAccounts.append(
                contentsOf: nondisplayedAccounts.filter {
                    $0.authAddress == account.address || $0.authAddress == account.authAddress
                }
            )
        }
    }

    func getVerifiedAccounts() -> [Account] {
        return verifiedAccounts
    }
}
