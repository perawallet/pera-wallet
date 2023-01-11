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

//   SwapSummaryReceivedItemViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryReceivedItemViewModel: SwapSummaryItemViewModel {
    private(set) var title: TextProvider?
    private(set) var value: TextProvider?

    private lazy var formatter = SwapAssetValueFormatter()

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

extension SwapSummaryReceivedItemViewModel {
    mutating func bindTitle() {
        title = "swap-summary-received-title"
            .localized
            .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindValue(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetOut = quote.assetOut,
              let totalReceivedAmount = quote.amountOutWithSlippage else {
            return
        }

        let decimalAmount = formatter.getDecimalAmount(
            of: totalReceivedAmount,
            for: assetOut
        )

        if assetOut.isAlgo {
            guard let amountText = formatter.getFormattedAlgoAmount(
                decimalAmount: decimalAmount,
                currencyFormatter: currencyFormatter
            ) else {
                return
            }

            bindDetail(
                text: "~+\(amountText)",
                textColor: Colors.Helpers.positive
            )

            return
        }

        let assetOutDisplayName = formatter.getAssetDisplayName(assetOut)
        guard let amountText = formatter.getFormattedAssetAmount(
            decimalAmount: decimalAmount,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetOut.decimals
        ) else {
            return
        }

        bindDetail(
            text: "~+\(amountText) \(assetOutDisplayName)",
            textColor: Colors.Helpers.positive
        )
    }

    mutating func bindDetail(
        text: String?,
        textColor: Color
    ) {
        var attributes = Typography.bodyLargeMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(textColor))
        value = text?.attributed(attributes)
    }
}
