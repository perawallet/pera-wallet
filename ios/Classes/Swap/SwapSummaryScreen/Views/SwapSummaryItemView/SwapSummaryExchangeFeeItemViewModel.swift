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

//   SwapSummaryExchangeFeeItemViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryExchangeFeeItemViewModel: SwapSummaryItemViewModel {
    private(set) var title: TextProvider?
    private(set) var value: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindValue(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapSummaryExchangeFeeItemViewModel {
    mutating func bindTitle() {
        title = "swap-confirm-exchange-fee-title"
            .localized
            .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindValue(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetIn = quote.assetIn,
              let exchangeFee = quote.exchangeFee else {
            return
        }

        let decimalAmount = swapAssetValueFormatter.getDecimalAmount(
            of: exchangeFee,
            for: assetIn
        )

        if assetIn.isAlgo {
            let text = swapAssetValueFormatter.getFormattedAlgoAmount(
                decimalAmount: decimalAmount,
                currencyFormatter: currencyFormatter
            )
            bindValue(text: text)
            return
        }

        let assetInDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        guard let formattedAmount = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: decimalAmount,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetIn.decimals
        ) else {
            return
        }

        bindValue(text: "~\(formattedAmount) \(assetInDisplayName)")
    }

    mutating func bindValue(text: String?) {
        value = text?.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
