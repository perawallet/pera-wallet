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

//   RekeySummaryInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeySummaryInfoViewModel: RekeyInfoViewModel {
    private(set) var title: TextProvider?
    private(set) var sourceAccountItem: AccountListItemViewModel?
    private(set) var authAccountItem: AccountListItemViewModel?

    init(
        sourceAccount: Account,
        authAccount: Account
    ) {
        bindTitle()
        bindSourceAccountItem(sourceAccount)
        bindAuthAccountItem(authAccount)
    }
}

extension RekeySummaryInfoViewModel {
    private mutating func bindTitle() {
        title =
            "summary-of-rekey-title"
                .localized
                .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindSourceAccountItem(_ sourceAccount: Account) {
        sourceAccountItem = AccountListItemViewModel(sourceAccount)
    }

    private mutating func bindAuthAccountItem(_ authAccount: Account) {
        authAccountItem = AccountListItemViewModel(authAccount)
    }
}
