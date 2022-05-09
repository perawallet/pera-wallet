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

struct TransactionCurrencyAmountViewModel:
    Hashable {
    private(set) var amountLabelText: EditText?
    private(set) var amountLabelColor: UIColor?
    private(set) var currencyLabelText: EditText?

    init(
        _ mode: TransactionAmountView.Mode,
        showAbbreviation: Bool = false
    ) {
        bindMode(mode, showAbbreviation: showAbbreviation)
    }
}

extension TransactionCurrencyAmountViewModel {
    private mutating func bindMode(
        _ mode: TransactionAmountView.Mode,
        showAbbreviation: Bool
    ) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol, currency):
            bindAmount(amount, showAbbreviation: showAbbreviation, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol, currency: currency)
        case let .positive(amount, isAlgos, assetFraction, assetSymbol, currency):
            bindAmount(amount, showAbbreviation: showAbbreviation, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol, currency: currency)
        case let .negative(amount, isAlgos, assetFraction, assetSymbol, currency):
            bindAmount(amount, showAbbreviation: showAbbreviation, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol, currency: currency)
        }
    }

    private mutating func bindAmount(
        _ amount: Decimal,
        showAbbreviation: Bool,
        with assetFraction: Int?,
        isAlgos: Bool,
        assetSymbol: String? = nil,
        currency: String? = nil
    ) {
        if isAlgos {
            amountLabelText = .string(showAbbreviation ? amount.toFullAlgosStringForLabel : amount.toAlgosStringForLabel)
            currencyLabelText = .string(currency)
            return
        }
        
        guard let fraction = assetFraction else {
            return
        }
        
        let amountText = amount.abbreviatedFractionStringForLabel(fraction: fraction) ?? ""
        
        if let assetSymbol = assetSymbol {
            amountLabelText = .string("\(amountText) \(assetSymbol)")
        } else {
            amountLabelText = .string(amountText)
        }
        
        amountLabelColor = AppColors.Components.Text.main.uiColor
        currencyLabelText = .string(currency)
    }
}
