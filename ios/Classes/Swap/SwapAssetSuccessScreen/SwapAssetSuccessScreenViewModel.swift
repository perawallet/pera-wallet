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

//   SwapAssetSuccessScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapAssetSuccessScreenViewModel {
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        parsedSwapTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(quote)
        bindDetail(
            quote: quote,
            parsedSwapTransactions: parsedSwapTransactions,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapAssetSuccessScreenViewModel {
    mutating func bindTitle(
        _ quote: SwapQuote
    ) {
        guard let assetIn = quote.assetIn,
              let assetOut = quote.assetOut else {
            return
        }

        let assetInDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        let assetOutDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetOut)
        let swapAssets = "\(assetInDisplayName) / \(assetOutDisplayName)"
        title = "swap-success-title"
            .localized(params: swapAssets)
            .bodyLargeMedium(alignment: .center)
    }

    mutating func bindDetail(
        quote: SwapQuote,
        parsedSwapTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        guard let amountIn = quote.amountIn,
              let assetIn = quote.assetIn,
              let assetOut = quote.assetOut,
              let amountOut = quote.amountOutWithSlippage else {
            return
        }

        var constraintRules = CurrencyFormattingContextRules()
        constraintRules.maximumFractionDigits = assetOut.decimals
        currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        currencyFormatter.currency = nil
        let amountOutDecimalAmount = amountOut.assetAmount(fromFraction: assetOut.decimals)
        guard let amountOutText = currencyFormatter.format(amountOutDecimalAmount) else { return }

        constraintRules.maximumFractionDigits = assetIn.decimals
        currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        currencyFormatter.currency = nil
        let amountInDecimalAmount = amountIn.assetAmount(fromFraction: assetIn.decimals)
        guard let amountInText = currencyFormatter.format(amountInDecimalAmount) else { return }

        let assetInDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        let assetOutDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetOut)

        let amountOutDisplay = "\(amountOutText) \(assetOutDisplayName)"
        let amountInDisplay = "\(amountInText) \(assetInDisplayName)"
        let fullText = "swap-success-detail".localized(params: amountOutDisplay, amountInDisplay)

        let textAttributes = NSMutableAttributedString(
            attributedString: fullText.bodyRegular(alignment: .center, lineBreakMode: .byWordWrapping)
        )

        var highlightedTextAttributes = Typography.bodyRegularAttributes(lineBreakMode: .byWordWrapping)
        highlightedTextAttributes.insert(.textColor(Colors.Text.main))

        let amountInDisplayRange = (textAttributes.string as NSString).range(of: amountInDisplay)
        let amountOutDisplayRange = (textAttributes.string as NSString).range(of: amountOutDisplay)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: amountInDisplayRange
        )

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: amountOutDisplayRange
        )

        detail = textAttributes
    }
}
