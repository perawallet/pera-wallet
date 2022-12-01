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

//   SwapAssetLoadingScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapAssetLoadingScreenViewModel: LoadingScreenViewModel {
    private(set) var imageName: String?
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        bindImageName()
        bindTitle()
        bindDetail(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapAssetLoadingScreenViewModel {
    mutating func bindImageName() {
        imageName = "pera_loader_240x240"
    }

    mutating func bindTitle() {
        title = "swap-loading-title"
            .localized
            .bodyLargeMedium(alignment: .center)
    }

    mutating func bindDetail(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let amountOut = quote.amountOutWithSlippage,
              let assetOut = quote.assetOut else {
            return
        }

        let assetOutDisplayName = swapAssetValueFormatter.getAssetDisplayName(assetOut)
        let decimalAmount = swapAssetValueFormatter.getDecimalAmount(
            of: amountOut,
            for: assetOut
        )

        var constraintRules = CurrencyFormattingContextRules()
        constraintRules.maximumFractionDigits = assetOut.decimals
        currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        currencyFormatter.currency = nil

        guard let amountText = currencyFormatter.format(decimalAmount) else { return }

        let assetText = "\(amountText) \(assetOutDisplayName)"

        let fullText = "swap-loading-detail".localized(params: assetText).localized
        let textAttributes = NSMutableAttributedString(
            attributedString: fullText.bodyRegular(alignment: .center, lineBreakMode: .byWordWrapping)
        )

        var highlightedTextAttributes = Typography.bodyRegularAttributes(lineBreakMode: .byWordWrapping)
        highlightedTextAttributes.insert(.textColor(Colors.Text.main))

        let highlightedTextRange = (textAttributes.string as NSString).range(of: assetText)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: highlightedTextRange
        )

        detail = textAttributes
    }
}
