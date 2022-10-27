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

//   WCConnectionAccountSelectionViewModel.swift

import UIKit
import MacaroonUIKit

struct WCConnectionAccountSelectionViewModel: ViewModel {
    private(set) var icon: UIImage?
    private(set) var title: String?
    private(set) var subtitle: String?

    init(
        _ account: Account
    ) {
        bindIcon(account)
        bindTitle(account)
        bindSubtitle(account)
    }
}

extension WCConnectionAccountSelectionViewModel {
    private mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.typeImage
    }

    private mutating func bindTitle(
        _ account: Account
    ) {
        title = AccountNaming.getPrimaryName(for: account)
    }

    private mutating func bindSubtitle(
        _ account: Account
    ) {
        subtitle = AccountNaming.getSecondaryName(for: account)
    }
}
