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

//
//  AssetViewModel.swift

import UIKit
import MacaroonUIKit

struct AssetViewModel: ViewModel {
    private(set) var amount: String?
    private(set) var valueInCurrency: String?
    private(set) var valueInUSD: Decimal = 0

    init(
        _ model: AssetItem
    ) {
        bind(model)
    }
}

extension AssetViewModel {
    mutating func bind(
        _ item: AssetItem
    ) {
        bindAmount(item)
        bindValue(item)
    }

    mutating func bindAmount(
        _ item: AssetItem
    ) {
        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        formatter.currency = nil

        amount = formatter.format(asset.decimalAmount)
    }

    mutating func bindValue(
        _ item: AssetItem
    ) {
        let asset = item.asset

        valueInUSD = asset.totalUSDValue ?? 0

        guard let currencyValue = item.currency.primaryValue else {
            valueInCurrency = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            let formatter = item.currencyFormatter
            formatter.formattingContext = item.currencyFormattingContext ?? .listItem
            formatter.currency = rawCurrency

            valueInCurrency = formatter.format(amount)
        } catch {
            valueInCurrency = nil
        }
    }
}
