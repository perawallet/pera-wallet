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

//   SwapAssetValueFormatter.swift

import Foundation

struct SwapAssetValueFormatter {
    func getAssetDisplayName(
        _ asset: AssetDecoration
    ) -> String {
        return
            asset.unitName ??
            asset.name ??
            "\(asset.id)"
    }

    func getFormattedAlgoAmount(
        decimalAmount: Decimal,
        currencyFormatter: CurrencyFormatter
    ) -> String? {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()
        return currencyFormatter.format(decimalAmount)
    }

    func getFormattedAssetAmount(
        decimalAmount: Decimal,
        currencyFormatter: CurrencyFormatter,
        maximumFractionDigits: Int
    ) -> String? {
        var constraintRules = CurrencyFormattingContextRules()
        constraintRules.maximumFractionDigits = maximumFractionDigits
        currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        currencyFormatter.currency = nil
        return currencyFormatter.format(decimalAmount)
    }

    func getDecimalAmount(
        of value: UInt64,
        for asset: AssetDecoration
    ) -> Decimal {
        return Decimal(
            sign: .plus,
            exponent: -asset.decimals,
            significand: Decimal(value)
        )
    }
}
