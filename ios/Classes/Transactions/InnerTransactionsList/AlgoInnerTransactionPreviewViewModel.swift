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

//   AlgoInnerTransactionPreviewViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgoInnerTransactionPreviewViewModel:
    InnerTransactionPreviewViewModel {
    var title: EditText?
    var amountViewModel: TransactionAmountViewModel?
    
    init(
        transaction: Transaction,
        account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(transaction)
        bindAmount(
            transaction: transaction,
            account: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AlgoInnerTransactionPreviewViewModel {
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
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let payment = transaction.payment else {
            return
        }

        if payment.receiver == transaction.sender {
            amountViewModel = TransactionAmountViewModel(
                .normal(
                    amount: payment.amountForTransaction(
                        includesCloseAmount: true
                    ).toAlgos
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if payment.receiver == account.address {
            amountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: payment.amountForTransaction(
                        includesCloseAmount: true
                    ).toAlgos
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
                    amount: payment.amountForTransaction(
                        includesCloseAmount: true
                    ).toAlgos
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: payment.amountForTransaction(
                    includesCloseAmount: true
                ).toAlgos
            ),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
}
