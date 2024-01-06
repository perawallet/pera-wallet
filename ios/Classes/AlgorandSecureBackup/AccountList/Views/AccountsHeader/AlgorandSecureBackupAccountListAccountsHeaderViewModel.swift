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

//   AlgorandSecureBackupAccountListAccountsHeaderViewModel.swift

import UIKit
import MacaroonUIKit

struct AlgorandSecureBackupAccountListAccountsHeaderViewModel:
    ViewModel,
    Hashable {
    var hasSingularAccount: Bool {
        return accountsCount == 1
    }

    private(set) var info: TextProvider?

    private let accountsCount: Int

    init(
        accountsCount: Int
    ) {
        self.accountsCount = accountsCount

        bindInfo(accountsCount)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(info?.string)
    }

    static func == (
        lhs: AlgorandSecureBackupAccountListAccountsHeaderViewModel,
        rhs: AlgorandSecureBackupAccountListAccountsHeaderViewModel
    ) -> Bool {
        return lhs.info?.string == rhs.info?.string
    }
}

extension AlgorandSecureBackupAccountListAccountsHeaderViewModel {
    private mutating func bindInfo(
        _ accountsCount: Int
    ) {
        let info: String

        if hasSingularAccount {
            info = "title-plus-account-singular-count".localized
        } else {
            info = "title-plus-account-count".localized(params: "\(accountsCount)")
        }

        self.info = info.bodyMedium(lineBreakMode: .byTruncatingTail)
    }
}
