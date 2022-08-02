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

//   AssetTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetTransactionItemViewModel:
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
              let assetTransfer = transaction.assetTransfer else {
            return
        }

        if let closeToAddress = transaction.getCloseAddress() {
            if closeToAddress == draft.account.address {
                bindTitle("transaction-item-receive-opt-out".localized)
                return
            }

            bindTitle("transaction-item-opt-out".localized)
            return
        }

        if transaction.sender == draft.account.address &&
            transaction.isSelfTransaction {
            if transaction.getAmount() != 0 {
                bindTitle("transaction-item-self-transfer".localized)
                return
            }

            bindTitle("transaction-item-opt-in".localized)
            return
        }

        if draft.account.address == assetTransfer.receiverAddress {
            bindTitle("transaction-detail-receive".localized)
            return
        }

        bindTitle("transaction-detail-send".localized)
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let assetTransfer = transaction.assetTransfer else {
                  return
        }

        if transaction.isSelfTransaction {
            subtitle = nil
            return
        }

        if let closeAddress = transaction.getCloseAddress() {
            let subtitle = getSubtitle(
                from: draft,
                for: closeAddress
            )
            bindSubtitle(subtitle)
            return
        }

        if isReceivingTransaction(draft, for: assetTransfer) {
            let subtitle = getSubtitle(
                from: draft,
                for: transaction.sender
            )
            bindSubtitle(subtitle)
            return
        }

        let subtitle = getSubtitle(
            from: draft,
            for: assetTransfer.receiverAddress
        )
        bindSubtitle(subtitle)
    }

    private mutating func bindAmount(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let assetTransfer = transaction.assetTransfer,
              let assetID = transaction.assetTransfer?.assetId,
              let asset = draft.localAssets?[assetID] else {
                  return
        }

        if assetTransfer.receiverAddress == transaction.sender {
            transactionAmountViewModel = TransactionAmountViewModel(
                .normal(
                    amount: assetTransfer.amount.assetAmount(fromFraction: asset.decimals),
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

        if assetTransfer.receiverAddress == draft.account.address {
            transactionAmountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: assetTransfer.amount.assetAmount(fromFraction: asset.decimals),
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
                amount: assetTransfer.amount.assetAmount(fromFraction: asset.decimals),
                isAlgos: false,
                fraction: asset.decimals,
                assetSymbol: getAssetSymbol(from: asset)
            ),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }

    private func isReceivingTransaction(
        _ draft: TransactionViewModelDraft,
        for assetTransfer: AssetTransferTransaction
    ) -> Bool {
        return draft.account.address == assetTransfer.receiverAddress
    }
}
