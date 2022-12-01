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

//   SwapAssetAmountOutInputViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapAssetAmountOutInputViewModel: AssetAmountInputViewModel {
    private(set) var imageSource: ImageSource?
    private(set) var primaryValue: TextProvider?
    let isInputEditable = false
    private(set) var detail: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        asset: Asset,
        swapQuote: SwapQuote?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindIcon(asset)
        bindPrimaryValue(
            asset: asset,
            swapQuote: swapQuote,
            currencyFormatter: currencyFormatter
        )
        bindDetail(
            asset: asset,
            swapQuote: swapQuote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapAssetAmountOutInputViewModel {
    mutating func bindIcon(
        _ asset: Asset
    ) {
        imageSource = getImageSource(asset)
    }

    mutating func bindPrimaryValue(
        asset: Asset,
        swapQuote: SwapQuote?,
        currencyFormatter: CurrencyFormatter
    ) {
        if let swapQuote,
           let amountOut = swapQuote.amountOut {
            let amount = swapAssetValueFormatter.getDecimalAmount(of: amountOut, for: AssetDecoration(asset: asset))
            primaryValue = Formatter.decimalFormatter(maximumFractionDigits: asset.decimals).string(from: NSDecimalNumber(decimal: amount))
        } else {
            primaryValue = "0.00"
        }
    }

    mutating func bindDetail(
        asset: Asset,
        swapQuote: SwapQuote?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindDetailAlgoValue(
                swapQuote: swapQuote,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindDetailAssetValue(
                asset: asset,
                swapQuote: swapQuote,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }

    mutating func bindDetailAlgoValue(
        swapQuote: SwapQuote?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        detail = getDetailValueForAlgo(
            value: swapQuote?.amountOutUSDValue,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindDetailAssetValue(
        asset: Asset,
        swapQuote: SwapQuote?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        detail = getDetailValueForAsset(
            asset,
            value: swapQuote?.amountOutUSDValue,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}
