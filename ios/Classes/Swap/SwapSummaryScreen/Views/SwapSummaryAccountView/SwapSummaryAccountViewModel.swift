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

//   SwapSummaryAccountViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryAccountViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var accountName: TextProvider?

    init(
        _ account: Account
    ) {
        bindIcon(account)
        bindAccount(account)
    }
}

extension SwapSummaryAccountViewModel {
    mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.typeImage
    }

    mutating func bindAccount(
        _ account: Account
    ) {
        accountName = account
            .name
            .unwrap(or: account.address.shortAddressDisplay)
            .bodyRegular(lineBreakMode: .byTruncatingMiddle)
    }
}
