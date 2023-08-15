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

//   UndoRekeyListItemButtonViewModel.swift

import Foundation
import MacaroonUIKit

struct UndoRekeyListItemButtonViewModel: ListItemButtonViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?

    init(authAccount: Account) {
        bindIcon()
        bindTitle()
        bindSubtitle(authAccount)
    }
}

extension UndoRekeyListItemButtonViewModel {
    private mutating func bindIcon() {
        icon = "icon-options-rekey"
    }

    private mutating func bindTitle() {
        let aTitle = "undo-rekey-title".localized
        title = Self.getTitle(aTitle)
    }

    private mutating func bindSubtitle(_ authAccount: Account) {
        let aSubtitle = "title-rekeyed-to-with-param".localized(params: authAccount.primaryDisplayName)
        subtitle = .attributedString(
            aSubtitle.captionRegular(
                lineBreakMode: .byTruncatingTail
            )
        )
    }
}
