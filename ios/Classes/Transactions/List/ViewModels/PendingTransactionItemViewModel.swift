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

//   PendingTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct PendingTransactionItemViewModel:
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
        if let pendingTransaction = draft.transaction as? PendingTransaction {
            id = "\(pendingTransaction.hashValue)"
        }
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? PendingTransaction else {
            return
        }

        if transaction.receiver == draft.account.address {
            bindTitle("transaction-detail-receive".localized)
            return
        }

        bindTitle("transaction-detail-send".localized)
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? PendingTransaction else {
            return
        }

        if transaction.receiver == transaction.sender {
            subtitle = nil
            return
        }

        if transaction.receiver == draft.account.address {
            let subtitle = getSubtitle(
                from: draft,
                for: transaction.sender
            )
            bindSubtitle(subtitle)
            return
        }

        let subtitle = getSubtitle(
            from: draft,
            for: transaction.receiver
        )
        bindSubtitle(subtitle)
    }

    private mutating func bindAmount(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transaction = draft.transaction as? PendingTransaction else {
            return
        }

        if let asset = draft.asset {
            bindAssetAmount(
                of: transaction,
                for: draft.account,
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            return
        }

        bindAlgoAmount(
            of: transaction,
            for: draft.account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    private mutating func bindAssetAmount(
        of transaction: PendingTransaction,
        for account: Account,
        asset: AssetDecoration,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if transaction.receiver == transaction.sender {
            transactionAmountViewModel = TransactionAmountViewModel(
                .normal(
                    amount: transaction.amount.assetAmount(fromFraction: asset.decimals),
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(from: asset)
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.receiver == account.address {
            transactionAmountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: transaction.amount.assetAmount(fromFraction: asset.decimals),
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(from: asset)
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            .negative(
                amount: transaction.amount.assetAmount(fromFraction: asset.decimals),
                isAlgos: false,
                fraction: asset.decimals,
                assetSymbol: getAssetSymbol(from: asset)
            ),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }

    private mutating func bindAlgoAmount(
        of transaction: PendingTransaction,
        for account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if transaction.receiver == transaction.sender {
            transactionAmountViewModel = TransactionAmountViewModel(
                .normal(amount: transaction.amount.toAlgos),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.receiver == account.address {
            transactionAmountViewModel = TransactionAmountViewModel(
                .normal(amount: transaction.amount.toAlgos),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            .normal(amount: transaction.amount.toAlgos),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
}
