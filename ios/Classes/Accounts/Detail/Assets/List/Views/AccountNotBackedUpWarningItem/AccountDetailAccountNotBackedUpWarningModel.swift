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

//   AccountDetailAccountNotBackedUpWarningModel.swift

import MacaroonUIKit

struct AccountDetailAccountNotBackedUpWarningModel: 
    ActionableBannerViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var message: EditText?
    private(set) var actionTitle: EditText?

    init() {
        bindIcon()
        bindTitle()
        bindActionTitle()
    }

    static func == (
        lhs: AccountDetailAccountNotBackedUpWarningModel,
        rhs: AccountDetailAccountNotBackedUpWarningModel
    ) -> Bool {
        return lhs.actionTitle == rhs.actionTitle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(actionTitle)
    }
}

extension AccountDetailAccountNotBackedUpWarningModel {
    private mutating func bindIcon() {
        icon = "icon-info-18".templateImage
    }

    private  mutating func bindTitle() {
        title = .attributedString(
            "account-not-backed-up-warning-title"
                .localized
                .footnoteMedium()
        )
    }

    private  mutating func bindActionTitle() {
        actionTitle = .attributedString(
            "account-not-backed-up-warning-action-title"
                .localized
                .footnoteMedium(lineBreakMode: .byTruncatingTail)
        )
    }
}
