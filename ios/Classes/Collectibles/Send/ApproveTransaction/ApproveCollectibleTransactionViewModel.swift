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

//   ApproveCollectibleTransactionViewModel.swift

import MacaroonUIKit
import UIKit

struct ApproveCollectibleTransactionViewModel: ViewModel {
    private(set) var senderAccountViewModel: CollectibleTransactionInfoViewModel?
    private(set) var toAccountViewModel: CollectibleTransactionInfoViewModel?
    private(set) var transactionFeeViewModel: CollectibleTransactionInfoViewModel?

    init(
        _ draft: SendCollectibleDraft,
        currencyFormatter: CurrencyFormatter
    ) {
        bind(
            draft,
            currencyFormatter: currencyFormatter
        )
    }
}

extension ApproveCollectibleTransactionViewModel {
    private mutating func bind(
        _ draft: SendCollectibleDraft,
        currencyFormatter: CurrencyFormatter
    ) {
        bindSenderAccount(draft)
        bindToAccount(draft)
        bindTransactionFee(
            draft,
            currencyFormatter: currencyFormatter
        )
    }
}

extension ApproveCollectibleTransactionViewModel {
    private mutating func bindSenderAccount(
        _ draft: SendCollectibleDraft
    ) {
        let info = CollectibleTransactionInformation(
            icon: .account(draft.fromAccount),
            title: "collectible-approve-transaction-sender".localized,
            value: draft.fromAccount.address.shortAddressDisplay
        )
        senderAccountViewModel = CollectibleTransactionInfoViewModel(info)
    }

    private mutating func bindToAccount(
        _ draft: SendCollectibleDraft
    ) {
        var value: String = .empty

        if let toContact = draft.toContact,
           let address = toContact.address {
            value = toContact.name ?? address.shortAddressDisplay
        } else if let toNameService = draft.toNameService {
            value = toNameService.name
        } else if let toAccount = draft.toAccount {
            value = toAccount.address.shortAddressDisplay
        }

        var icon: CollectibleTransactionInformation.Icon?
        if let contact = draft.toContact {
            icon = .contact(contact)
        } else if let nameService = draft.toNameService {
            icon = .nameService(nameService)
        } else if let account = draft.toAccount {
            icon = .account(account)
        }

        let info = CollectibleTransactionInformation(
            icon: icon,
            title: "collectible-approve-transaction-to".localized,
            value: value
        )
        toAccountViewModel = CollectibleTransactionInfoViewModel(info)
    }

    private mutating func bindTransactionFee(
        _ draft: SendCollectibleDraft,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fee = draft.fee else {
            return
        }

        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()

        let feeText = currencyFormatter.format(fee.toAlgos)
        let info = CollectibleTransactionInformation(
            title: "collectible-approve-transaction-fee".localized,
            value: feeText.someString
        )

        transactionFeeViewModel = CollectibleTransactionInfoViewModel(info)
    }
}
