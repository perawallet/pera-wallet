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

//   AccountNameTitleViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AccountNameTitleViewModel: BindableViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: ImageStyle?
    private(set) var subtitle: TextProvider?

    init<T>(_ model: T) {
        bind(model)
    }
}

extension AccountNameTitleViewModel {
    mutating func bind<T>(_ model: T) {
        if let account = model as? Account {
            bindTitle(account)
            bindSubtitle(account)
            return
        }

        if let draft = model as? SendTransactionAccountNameTitleDraft {
            bindTitle(draft)
            bindIcon(draft)
            bindSubtitle(draft)
            return
        }
    }
}

// MARK: - Account

extension AccountNameTitleViewModel {
    mutating func bindTitle(_ account: Account) {
        let title = AccountNaming.getPrimaryName(for: account)

        self.title = title.bodyRegular(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSubtitle(_ account: Account) {
        let subtitle = AccountNaming.getSecondaryName(for: account)

        self.subtitle = subtitle?.footnoteRegular(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}

// MARK: - SendTransactionAccountNameTitleDraft

extension AccountNameTitleViewModel {
    mutating func bindTitle(_ draft: SendTransactionAccountNameTitleDraft) {
        let title: String

        switch draft.transactionMode {
        case .asset(let asset):
            title = "send-transaction-title".localized(asset.naming.displayNames.primaryName)
        case .algo:
            title = "send-transaction-title".localized("asset-algos-title".localized)
        }

        self.title = title.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindIcon(_ draft: SendTransactionAccountNameTitleDraft) {
        let image = draft.account.typeImage
        let resizedImage =
            image
                .convert(to: CGSize((16, 16)))
                .unwrap(or: image)

        icon = [
            .image(resizedImage),
            .contentMode(.left)
        ]
    }

    mutating func bindSubtitle(_ draft: SendTransactionAccountNameTitleDraft) {
        let subtitle = AccountNaming.getPrimaryName(for: draft.account)

        self.subtitle = subtitle.footnoteRegular(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}

struct SendTransactionAccountNameTitleDraft {
    let transactionMode: TransactionMode
    let account: Account
}
