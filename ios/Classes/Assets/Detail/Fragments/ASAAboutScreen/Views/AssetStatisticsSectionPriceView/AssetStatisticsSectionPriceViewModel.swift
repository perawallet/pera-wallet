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

//   AssetStatisticsSectionPriceViewModel.swift

import MacaroonUIKit

struct AssetStatisticsSectionPriceViewModel: PrimaryTitleViewModel {
    var primaryTitle: TextProvider?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    init(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindSubtitle(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AssetStatisticsSectionPriceViewModel {
    mutating func bindTitle() {
        primaryTitle = "title-price"
            .localized
            .footnoteRegular(
                lineBreakMode: .byTruncatingTail
            )
    }

    mutating func bindSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoSubtitle(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetSubtitle(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }

    private mutating func bindAlgoSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fiatCurrencyValue = currency.fiatValue else {
            bindSubtitle(text: nil)
            return
        }

        do {
            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchangeAlgoToUSD(amount: 1)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            bindSubtitle(text: text)
        } catch {
            bindSubtitle(text: nil)
        }
    }

    private mutating func bindAssetSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = currency.primaryValue else {
            bindSubtitle(text: nil)
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(
                asset,
                amount: 1
            )

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            bindSubtitle(text: text)
        } catch {
            bindSubtitle(text: nil)
        }
    }

    mutating func bindSubtitle(text: String?) {
        secondaryTitle = (text ?? "-").bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }
}
