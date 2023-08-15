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

//   SwapConfirmExchangeFeeInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct SwapConfirmExchangeFeeInfoViewModel: SwapInfoItemViewModel {
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
            currencyFormatter: currencyFormatter
        )
        bindAction()
    }
}

extension SwapConfirmExchangeFeeInfoViewModel {
    mutating func bindTitle() {
        title = "swap-confirm-exchange-fee-title"
            .localized
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindIcon() {
        icon = "icon-info-20"
    }

    mutating func bindDetail(
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
            bindDetail(text: text)
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

        bindDetail(text: "~\(formattedAmount) \(assetInDisplayName)")
    }

    mutating func bindDetail(text: String?) {
        detail = text?.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAction() {
        action = nil
    }
}
