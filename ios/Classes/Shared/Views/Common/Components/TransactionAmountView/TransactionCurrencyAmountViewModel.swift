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
//   TransactionCurrencyAmountViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionCurrencyAmountViewModel: Hashable {
    private(set) var amountLabelText: EditText?
    private(set) var amountLabelColor: UIColor?
    private(set) var currencyLabelText: EditText?

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
}

extension TransactionCurrencyAmountViewModel {
    private mutating func bindMode(
        _ mode: TransactionAmountView.Mode,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool
    ) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol, currencySymbol):
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol,
                currencySymbol: currencySymbol
            )
        case let .positive(amount, isAlgos, assetFraction, assetSymbol, currencySymbol):
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol,
                currencySymbol: currencySymbol
            )
        case let .negative(amount, isAlgos, assetFraction, assetSymbol, currencySymbol):
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol,
                currencySymbol: currencySymbol
            )
        }
    }

    private mutating func bindAmount(
        _ amount: Decimal,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool,
        with assetFraction: Int?,
        isAlgos: Bool,
        assetSymbol: String? = nil,
        currencySymbol: String? = nil
    ) {
        if isAlgos {
            currencyFormatter.formattingContext = showAbbreviation ? .listItem : .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let text = currencyFormatter.format(amount)

            amountLabelText = .string(text)
            currencyLabelText = .string(currencySymbol)

            return
        }

        if showAbbreviation {
            currencyFormatter.formattingContext = .listItem
        } else {
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = assetFraction

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        }

        currencyFormatter.currency = nil

        let amountText = currencyFormatter.format(amount)
        let text = [ amountText, assetSymbol ].compound(" ")

        amountLabelText = .string(text)
        amountLabelColor = Colors.Text.main.uiColor
        currencyLabelText = .string(currencySymbol)
    }
}
