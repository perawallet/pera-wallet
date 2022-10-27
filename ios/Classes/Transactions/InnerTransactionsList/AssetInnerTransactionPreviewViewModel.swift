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

//   AssetInnerTransactionPreviewViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetInnerTransactionPreviewViewModel:
    InnerTransactionPreviewViewModel {
    var title: EditText?
    var amountViewModel: TransactionAmountViewModel?

    init(
        transaction: Transaction,
        account: Account,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(transaction)
        bindAmount(
            transaction: transaction,
            account: account,
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AssetInnerTransactionPreviewViewModel {
    private mutating func bindTitle(
        _ transaction: Transaction
    ) {
        title = Self.getTitle(
            transaction.sender.shortAddressDisplay
        )
    }

    private mutating func bindAmount(
        transaction: Transaction,
        account: Account,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetTransfer = transaction.assetTransfer,
              let asset = asset else {
            return
        }

        if assetTransfer.receiverAddress == transaction.sender {
            amountViewModel = TransactionAmountViewModel(
                .normal(
                    amount: assetTransfer.amount.assetAmount(
                        fromFraction: asset.decimals
                    ),
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if assetTransfer.receiverAddress == account.address {
            amountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: assetTransfer.amount.assetAmount(
                        fromFraction: asset.decimals
                    ),
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.sender == account.address {
            amountViewModel = TransactionAmountViewModel(
                .negative(
                    amount: assetTransfer.amount.assetAmount(
                        fromFraction: asset.decimals
                    ),
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            return
        }

        amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: assetTransfer.amount.assetAmount(
                    fromFraction: asset.decimals
                ),
                isAlgos: false,
                fraction: asset.decimals,
                assetSymbol: getAssetSymbol(
                    from: asset
                )
            ),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
}
