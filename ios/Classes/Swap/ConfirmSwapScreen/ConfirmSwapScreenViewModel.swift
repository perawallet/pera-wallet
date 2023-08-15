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

//   ConfirmSwapScreenViewModel.swift

import Foundation
import MacaroonUIKit

struct ConfirmSwapScreenViewModel: ViewModel {
    private(set) var userAsset: SwapAssetAmountViewModel?
    private(set) var toSeparator: TitleSeparatorViewModel?
    private(set) var poolAsset: SwapAssetAmountViewModel?
    private(set) var warning: ErrorViewModel?
    private(set) var priceInfo: SwapInfoItemViewModel?
    private(set) var slippageInfo: SwapInfoItemViewModel?
    private(set) var priceImpactInfo: SwapInfoItemViewModel?
    private(set) var minimumReceivedInfo: SwapInfoItemViewModel?
    private(set) var exchangeFeeInfo: SwapInfoItemViewModel?
    private(set) var peraFeeInfo: SwapInfoItemViewModel?
    private(set) var isConfirmActionEnabled: Bool = true

    init(
        account: Account,
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindUserAsset(
            account: account,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindToSeparator()
        bindPoolAsset(
            account: account,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindWarning(quote)
        bindPriceInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindSlippageInfo(quote)
        bindPriceImpactInfo(quote)
        bindMinimumReceivedInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindExchangeFeeInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindPeraFeeInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindIsConfirmActionEnabled(quote)
    }
}

extension ConfirmSwapScreenViewModel {
    mutating func bindUserAsset(
        account: Account,
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetIn = quote.assetIn else { return }

        let asset: Asset

        if assetIn.isAlgo {
            asset = account.algo
        } else if assetIn.isCollectible {
            asset = CollectibleAsset(decoration: assetIn)
        } else {
            asset = StandardAsset(decoration: assetIn)
        }

        userAsset = ConfirmSwapAmountInViewModel(
            asset: asset,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindToSeparator() {
        toSeparator = TitleSeparatorViewModel(
            "title-to"
                .localized
                .uppercased()
        )
    }

    mutating func bindPoolAsset(
        account: Account,
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetOut = quote.assetOut else { return }

        let asset: Asset
        if assetOut.isAlgo {
            asset = account.algo
        } else if assetOut.isCollectible {
            asset = CollectibleAsset(decoration: assetOut)
        } else {
            asset = StandardAsset(decoration: assetOut)
        }

        poolAsset = ConfirmSwapAmountOutViewModel(
            asset: asset,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindWarning(
        _ quote: SwapQuote
    ) {
        guard let priceImpact = quote.priceImpact else {
            warning = nil
            return
        }

        let message: String?
        let messageHighlightedText: String?
        let messageHighlightedTextURL: URL?

        switch priceImpact {
        case ...PriceImpactLimit.fivePercent:
            message = nil
            messageHighlightedText = nil
            messageHighlightedTextURL = nil
        case PriceImpactLimit.fivePercent...PriceImpactLimit.tenPercent:
            message = "swap-price-impact-warning-message".localized
            messageHighlightedText = nil
            messageHighlightedTextURL = nil
        case PriceImpactLimit.tenPercent...PriceImpactLimit.fifteenPercent:
            message = "swap-price-impact-greater-than-10-warning-message".localized
            messageHighlightedText = nil
            messageHighlightedTextURL = nil
        default:
            message = "swap-price-impact-greater-than-15-warning-message".localized
            messageHighlightedText = "swap-price-impact-greater-than-15-warning-message-highlighted-text".localized
            messageHighlightedTextURL = AlgorandWeb.tinymanSwapPriceImpact.link
        }

        guard let message else {
            warning = nil
            return
        }

        warning = SwapAssetErrorViewModel(
            message: message,
            messageHighlightedText: messageHighlightedText,
            messageHighlightedTextURL: messageHighlightedTextURL
        )
    }

    mutating func bindPriceInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        priceInfo = SwapConfirmPriceInfoViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindSlippageInfo(
        _ quote: SwapQuote
    ) {
        slippageInfo = SwapConfirmSlippageToleranceInfoViewModel(quote)
    }

    mutating func bindPriceImpactInfo(
        _ quote: SwapQuote
    ) {
        priceImpactInfo = SwapConfirmPriceImpactInfoViewModel(quote)
    }

    mutating func bindMinimumReceivedInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        minimumReceivedInfo = SwapConfirmMinimumReceivedInfoViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindExchangeFeeInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        exchangeFeeInfo = SwapConfirmExchangeFeeInfoViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindPeraFeeInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        peraFeeInfo = SwapConfirmPeraFeeInfoViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindIsConfirmActionEnabled(
        _ quote: SwapQuote
    ) {
        guard let priceImpact = quote.priceImpact else {
            isConfirmActionEnabled = true
            return
        }

        isConfirmActionEnabled = priceImpact <= PriceImpactLimit.fifteenPercent
    }
}
