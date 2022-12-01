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

//   ConfirmSwapAmountInViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ConfirmSwapAmountInViewModel: SwapAssetAmountViewModel {
    private(set) var leftTitle: TextProvider?
    private(set) var rightTitle: TextProvider?
    private(set) var assetAmountValue: AssetAmountInputViewModel?
    private(set) var assetSelectionValue: SwapAssetSelectionViewModel?

    init(
        asset: Asset,
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindLeftTitle()
        bindRightTitle()
        bindAssetAmountValue(
            asset: asset,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindAssetSelectionValue(asset)
    }
}

extension ConfirmSwapAmountInViewModel {
    mutating func bindLeftTitle() {
        leftTitle = nil
    }

    mutating func bindRightTitle() {
        rightTitle = nil
    }

    mutating func bindAssetAmountValue(
        asset: Asset,
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        assetAmountValue = ConfirmSwapAmountInInputViewModel(
            asset: asset,
            swapQuote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindAssetSelectionValue(
        _ asset: Asset
    ) {
        assetSelectionValue = ConfirmSwapAssetSelectionViewModel(asset)
    }
}
