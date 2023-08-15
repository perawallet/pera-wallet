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

//   SwapConfirmPriceInfoViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapConfirmPriceInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var iconTintColor: Color?
    private(set) var detail: TextProvider?
    private(set) var action: Image?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindIcon()
        bindDetail(
            quote: quote,
            isPriceReversed: false,
            currencyFormatter: currencyFormatter
        )
        bindAction()
    }
}

extension SwapConfirmPriceInfoViewModel {
    mutating func bindTitle() {
        title = "title-price"
            .localized
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindDetail(
        quote: SwapQuote,
        isPriceReversed: Bool,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let amountIn = quote.amountIn,
              let amountOut = quote.amountOut,
              let assetIn = quote.assetIn,
              let assetOut = quote.assetOut else {
            return
        }

        let amountInDecimal = swapAssetValueFormatter.getDecimalAmount(
            of: amountIn,
            for: assetIn
        )
        let amountOutDecimal = swapAssetValueFormatter.getDecimalAmount(
            of: amountOut,
            for: assetOut
        )
        let priceValue = isPriceReversed ? amountInDecimal / amountOutDecimal : amountOutDecimal / amountInDecimal
        let firstAsset = !isPriceReversed ? assetOut: assetIn
        let secondAsset = !isPriceReversed ? assetIn: assetOut
        let firstAssetDisplayName = swapAssetValueFormatter.getAssetDisplayName(firstAsset)
        let secondAssetDisplayName = swapAssetValueFormatter.getAssetDisplayName(secondAsset)

        guard let formattedAmount = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: priceValue,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: firstAsset.decimals
        ) else {
            return
        }

        let assetText = "\(formattedAmount) \(firstAssetDisplayName)"
        detail = "swap-confirm-price-info"
            .localized(
                params: assetText, secondAssetDisplayName
            ).footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAction() {
        action = "icon-repeat"
    }
}
