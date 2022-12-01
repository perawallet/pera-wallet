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

//   ExportAccountsConfirmationListItemHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ExportAccountsConfirmationListItemHeaderViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?
    private let hasSingularAccount: Bool

    init(hasSingularAccount: Bool) {
        self.hasSingularAccount = hasSingularAccount
        bindTitle()
        bindTitleStyle()
    }
}

extension ExportAccountsConfirmationListItemHeaderViewModel {
    mutating func bindTitle() {
        let listTitle = hasSingularAccount ? "web-export-account-confirmation-list-description-singular".localized : "web-export-account-confirmation-list-description".localized

        self.title = .attributedString(listTitle.localized.bodyRegular())
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
    }
}
