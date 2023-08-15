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

//   AccountInformationNoAuthAccountItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AccountInformationNoAuthAccountItemViewModel: AccountListItemWithActionViewModel {
    private(set) var content: AccountListItemViewModel?
    private(set) var action: ButtonStyle?

    init(_ authAddress: PublicKey) {
        bindContent(authAddress)
        bindAccessory()
    }
}

extension AccountInformationNoAuthAccountItemViewModel {
    private mutating func bindContent(_ authAddress: PublicKey) {
        let shortAddressDisplay = authAddress.shortAddressDisplay
        let item = CustomAccountListItem(
            address: shortAddressDisplay,
            icon: "standard-gray".uiImage,
            title: shortAddressDisplay,
            subtitle: nil
        )
        content = AccountListItemViewModel(item)
    }

    private mutating func bindAccessory() {
        let icon = "badge-warning".uiImage
        let action: ButtonStyle = [
            .icon([ .normal(icon), .highlighted(icon)])
        ]
        self.action = action
    }
}
