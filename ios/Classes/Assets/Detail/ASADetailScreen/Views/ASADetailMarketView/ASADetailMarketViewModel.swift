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

//   ASADetailMarketViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailMarketViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var price: TextProvider?
    private(set) var priceChange: TextProvider?
    private(set) var priceChangeIcon: ImageSource?

    init(
        assetItem: AssetItem
    ) {
        let isAvailableOnDiscover = assetItem.asset.isAvailableOnDiscover

        guard isAvailableOnDiscover else {
            return
        }

        bindTitle()
        bindPrice(assetItem)
        bindPriceChange(assetItem)
        bindPriceChangeIcon(assetItem)
    }
}

extension ASADetailMarketViewModel {
    mutating private func bindTitle() {
        self.title = "asset-detail-markets-title".localized.footnoteRegular()
    }

    mutating private func bindPrice(_ item: AssetItem) {
        let amount: Decimal
        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem

        do {
            let exchanger: CurrencyExchanger
            if asset.isAlgo {
                guard let fiatCurrencyValue = item.currency.fiatValue else {
                    price = nil
                    return
                }

                let rawFiatCurrency = try fiatCurrencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawFiatCurrency)
                amount = try exchanger.exchangeAlgo(amount: 1)

                formatter.currency = rawFiatCurrency
            } else {
                guard let currencyValue = item.currency.primaryValue else {
                    price = nil
                    return
                }

                let rawCurrency = try currencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawCurrency)
                amount = try exchanger.exchange(asset, amount: 1)

                formatter.currency = rawCurrency
            }

            price = formatter.format(amount)?.footnoteMedium()
        } catch {
            price = nil
        }
    }

    mutating private func bindPriceChange(_ item: AssetItem) {
        let priceChangePercentage = item.asset.algoPriceChangePercentage

        guard priceChangePercentage != 0 else {
            priceChange = nil
            return
        }
        var attributes = Typography.footnoteMediumAttributes()

        let textColor = priceChangePercentage > 0 ? Colors.Helpers.positive : Colors.Helpers.negative
        attributes.insert(.textColor(textColor))
        
        priceChange = (priceChangePercentage / 100).toPercentage?.attributed(attributes)
    }

    mutating private func bindPriceChangeIcon(_ item: AssetItem){
        let priceChangePercentage = item.asset.algoPriceChangePercentage

        guard priceChangePercentage != 0 else {
            priceChangeIcon = nil
            return
        }

        priceChangeIcon = priceChangePercentage > 0 ? "icon-market-increase".uiImage : "icon-market-decrease".uiImage
    }
}
