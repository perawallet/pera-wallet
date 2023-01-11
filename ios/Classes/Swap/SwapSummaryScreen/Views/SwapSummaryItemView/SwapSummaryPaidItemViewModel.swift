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

//   SwapSummaryPaidItemViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryPaidItemViewModel: SwapSummaryItemViewModel {
    private(set) var title: TextProvider?
    private(set) var value: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindValue(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapSummaryPaidItemViewModel {
    mutating func bindTitle() {
        title = "swap-summary-paid-title"
            .localized
            .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindValue(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetIn = quote.assetIn,
              let totalPaidAmount = quote.amountInWithSlippage else {
            return
        }

        let decimalAmount = swapAssetValueFormatter.getDecimalAmount(
            of: totalPaidAmount,
            for: assetIn
        )

        if assetIn.isAlgo {
            guard let amountText = swapAssetValueFormatter.getFormattedAlgoAmount(
                decimalAmount: decimalAmount,
                currencyFormatter: currencyFormatter
            ) else {
                return
            }

            bindDetail(
                text: "-\(amountText)",
                textColor: Colors.Helpers.negative
            )

            return
        }

        let assetInDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        guard let amountText = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: decimalAmount,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetIn.decimals
        ) else {
            return
        }

        bindDetail(
            text: "-\(amountText) \(assetInDisplayName)",
            textColor: Colors.Helpers.negative
        )
    }

    mutating func bindDetail(
        text: String?,
        textColor: Color
    ) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(textColor))
        value = text?.attributed(attributes)
    }
}
