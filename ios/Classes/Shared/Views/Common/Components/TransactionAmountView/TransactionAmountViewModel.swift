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

//
//   TransactionAmountViewModel.swift

import MacaroonUIKit
import UIKit

struct TransactionAmountViewModel: Hashable {
    private(set) var signLabelText: EditText?
    private(set) var signLabelColor: UIColor?
    private(set) var amountLabelText: EditText?
    private(set) var amountLabelColor: UIColor?

    init(
        _ mode: TransactionAmountView.Mode,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool = false
    ) {
        bindMode(
            mode,
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: showAbbreviation
        )
    }

    init(
        innerTransactionCount: Int,
        showInList: Bool = true
    ) {
        bindInnerTransaction(count: innerTransactionCount, showInList: showInList)
    }
}

extension TransactionAmountViewModel {
    private mutating func bindMode(
        _ mode: TransactionAmountView.Mode,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool
    ) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = nil
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = Colors.Text.main.uiColor
        case let .positive(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "+"
            signLabelColor = Colors.Helpers.positive.uiColor
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = Colors.Helpers.positive.uiColor
        case let .negative(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "-"
            signLabelColor = Colors.Helpers.negative.uiColor
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = Colors.Helpers.negative.uiColor
        }
    }

    private mutating func bindAmount(
        _ amount: Decimal,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool,
        with assetFraction: Int?,
        isAlgos: Bool,
        assetSymbol: String? = nil
    ) {
        if isAlgos {
            currencyFormatter.formattingContext = showAbbreviation ? .listItem : .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let text = currencyFormatter.format(amount)
            amountLabelText = .string(text)

            return
        }

        if showAbbreviation {
            currencyFormatter.formattingContext = .listItem
        } else {
            /// <todo>
            /// Not sure we need this constraint, because the final number should be sent to the
            /// formatter unless the number itself is modified.
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = assetFraction

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        }

        currencyFormatter.currency = nil

        let amountText = currencyFormatter.format(amount)
        let text = [ amountText, assetSymbol ].compound(" ")

        amountLabelText = .string(text)
    }
}

/// <mark> Inner Transaction Binding
extension TransactionAmountViewModel {
    private mutating func bindInnerTransaction(count: Int, showInList: Bool) {
        amountLabelColor = Colors.Helpers.positive.uiColor

        if showInList {
            let aText = count == 1
            ? "inner-txns-singular-count".localized
            : "inner-txns-plural-count".localized(params: "\(count)")

            amountLabelText = .attributedString(
                aText.bodyMedium(
                    alignment: .right
                )
            )
            return
        }

        let aText = count == 1
        ?  "transaction-detail-singular-inner-transaction-detail".localized
        : "transaction-detail-plural-inner-transaction-detail".localized(params: "\(count)")

        amountLabelText = .attributedString(
            aText.bodyMedium(
                alignment: .right
            )
        )
    }
}
