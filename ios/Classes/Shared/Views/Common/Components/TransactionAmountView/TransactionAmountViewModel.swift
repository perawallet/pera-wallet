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

struct TransactionAmountViewModel:
    PairedViewModel,
    Hashable {
    private(set) var signLabelText: EditText?
    private(set) var signLabelColor: UIColor?
    private(set) var amountLabelText: EditText?
    private(set) var amountLabelColor: UIColor?

    init(
        _ mode: TransactionAmountView.Mode
    ) {
        bindMode(mode)
    }
}

extension TransactionAmountViewModel {
    private mutating func bindMode(
        _ mode: TransactionAmountView.Mode
    ) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = nil
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Components.Text.main.uiColor
        case let .positive(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "+"
            signLabelColor = AppColors.Shared.Helpers.positive.uiColor
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Shared.Helpers.positive.uiColor
        case let .negative(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "-"
            signLabelColor = AppColors.Shared.Helpers.negative.uiColor
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Shared.Helpers.negative.uiColor
        }
    }

    private mutating func bindAmount(
        _ amount: Decimal,
        with assetFraction: Int?,
        isAlgos: Bool,
        assetSymbol: String? = nil
    ) {
        if let fraction = assetFraction {
            amountLabelText = .string(amount.toFractionStringForLabel(fraction: fraction))
        } else {
            amountLabelText = .string(amount.toAlgosStringForLabel)
        }

        if isAlgos {
            amountLabelText = .string("\(amountLabelText?.string ?? "") ALGO")
        } else {
            if let assetSymbol = assetSymbol {
                amountLabelText = .string("\(amountLabelText?.string ?? "") \(assetSymbol)")
            }
        }
    }
}
