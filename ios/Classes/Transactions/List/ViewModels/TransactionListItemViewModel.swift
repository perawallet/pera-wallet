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

//   TransactionListItemViewModel.swift

import Foundation
import MacaroonUIKit

protocol TransactionListItemViewModel: ViewModel {
    var id: String? { get set }
    var title: EditText? { get set }
    var subtitle: EditText? { get set }
    var transactionAmountViewModel: TransactionAmountViewModel? { get set }
}

extension TransactionListItemViewModel where Self: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(transactionAmountViewModel)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.transactionAmountViewModel == rhs.transactionAmountViewModel
    }
}

extension TransactionListItemViewModel {
    func getSubtitle(
        from draft: TransactionViewModelDraft,
        for account: PublicKey?
    ) -> String? {
        if let contact = draft.contact {
            return contact.name
        }

        if let address = account,
           let localAccount = draft.localAccounts.first(matching: (\.address, address)) {
            return localAccount.primaryDisplayName
        }

        return account.shortAddressDisplay
    }

    func getAssetSymbol(
        from asset: AssetDecoration
    ) -> String {
        if let unitName = asset.unitName,
           !unitName.isEmptyOrBlank {
            return unitName
        }

        if let name = asset.name,
           !name.isEmptyOrBlank {
            return name
        }

        return "title-unknown".localized.uppercased()
    }
}

extension TransactionListItemViewModel {
    mutating func bindTitle(
        _ title: String?
    ) {
        guard let title = title else {
            self.title = nil
            return
        }

        self.title = .attributedString(
            title.bodyRegular(
                lineBreakMode: .byTruncatingTail
            )
        )
    }

    mutating func bindSubtitle(
        _ subtitle: String?
    ) {
        guard let subtitle = subtitle else {
            self.subtitle = nil
            return
        }

        self.subtitle = .attributedString(
            subtitle.footnoteRegular(
                lineBreakMode: .byTruncatingTail
            )
        )
    }
}
