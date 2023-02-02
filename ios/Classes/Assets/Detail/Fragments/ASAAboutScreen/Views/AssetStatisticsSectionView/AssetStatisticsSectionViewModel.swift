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

//   AssetStatisticsSectionViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetStatisticsSectionViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var price: PrimaryTitleViewModel?
    private(set) var totalSupply: PrimaryTitleViewModel?

    init(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        amountFormatter: CollectibleAmountFormatter
    ) {
        bindTitle()
        bindPrice(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindTotalSupply(
            asset: asset,
            amountFormatter: amountFormatter
        )
    }
}

extension AssetStatisticsSectionViewModel {
    mutating func bindTitle() {
        title = "algo-statistics-title"
            .localized
            .uppercased()
            .footnoteHeadingMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindPrice(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        price = AssetStatisticsSectionPriceViewModel(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindTotalSupply(
        asset: Asset,
        amountFormatter: CollectibleAmountFormatter
    ) {
        totalSupply = AssetStatisticsSectionTotalSupplyViewModel(
            asset: asset,
            amountFormatter: amountFormatter
        )
    }
}
