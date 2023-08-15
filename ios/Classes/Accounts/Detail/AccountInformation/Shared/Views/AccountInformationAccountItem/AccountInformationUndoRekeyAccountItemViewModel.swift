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

//   AccountInformationUndoRekeyAccountItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AccountInformationUndoRekeyAccountItemViewModel: AccountListItemWithActionViewModel {
    private(set) var content: AccountListItemViewModel?
    private(set) var action: ButtonStyle?

    init(_ account: Account) {
        bindContent(account)
        bindAccessory()
    }
}

extension AccountInformationUndoRekeyAccountItemViewModel {
    private mutating func bindContent(_ account: Account) {
        var viewModel = AccountListItemViewModel(account)
        viewModel.bindIcon(account.underlyingTypeImage)
        content = viewModel
    }

    private mutating func bindAccessory() {
        let titleColor = Colors.Helpers.positive
        let action: ButtonStyle = [
            .titleColor([ .normal(titleColor), .highlighted(titleColor) ]),
            .title("title-undo-rekey-capitalized-sentence".localized.footnoteMedium())
        ]
        self.action = action
    }
}
