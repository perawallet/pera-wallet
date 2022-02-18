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
//  LedgerAccountDetailViewModel.swift

import UIKit
import MacaroonUIKit

final class LedgerAccountDetailViewModel: ViewModel {
    private(set) var account: Account
    private(set) var rekeyedAccounts: [Account]?
    private(set) var subtitle: String?

    init(account: Account, rekeyedAccounts: [Account]?) {
        self.account = account
        self.rekeyedAccounts = rekeyedAccounts
        self.bindSubtitle(account)
    }
}

extension LedgerAccountDetailViewModel {
    private func bindSubtitle(_ account: Account) {
        subtitle = account.isRekeyed() ? "ledger-account-detail-can-signed".localized : "ledger-account-detail-can-sign".localized
    }
}
