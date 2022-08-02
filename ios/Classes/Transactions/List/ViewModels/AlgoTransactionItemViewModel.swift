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

//   AlgoTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgoTransactionItemViewModel:
    TransactionListItemViewModel,
    Hashable {
    var id: String?
    var title: EditText?
    var subtitle: EditText?
    var transactionAmountViewModel: TransactionAmountViewModel?

    init(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindID(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindAmount(
            draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        if let transaction = draft.transaction as? Transaction {
            id = transaction.id
        }
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let payment = transaction.payment else {
            return
        }
        
        if transaction.sender == draft.account.address && transaction.isSelfTransaction {
            bindTitle("transaction-item-self-transfer".localized)
            return
        }

        if isReceivingTransaction(draft, for: payment) {
            bindTitle("transaction-detail-receive".localized)
            return
        }
        
        bindTitle("transaction-detail-send".localized)
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let payment = transaction.payment else {
                  return
        }

        if transaction.isSelfTransaction {
            subtitle = nil
            return
        }

        if isReceivingTransaction(draft, for: payment) {
            let subtitle = getSubtitle(
                from: draft,
                for: transaction.sender
            )
            bindSubtitle(subtitle)
            return
        }

        let subtitle = getSubtitle(
            from: draft,
            for: payment.receiver
        )
        bindSubtitle(subtitle)
    }

    private mutating func bindAmount(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let payment = transaction.payment else {
                  return
        }

        if payment.receiver == transaction.sender {
            transactionAmountViewModel = TransactionAmountViewModel(
                .normal(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if payment.receiver == draft.account.address {
            transactionAmountViewModel = TransactionAmountViewModel(
                .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            .negative(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }

    private func isReceivingTransaction(
        _ draft: TransactionViewModelDraft,
        for payment: Payment
    ) -> Bool {
        return draft.account.address == payment.receiver
    }
}
