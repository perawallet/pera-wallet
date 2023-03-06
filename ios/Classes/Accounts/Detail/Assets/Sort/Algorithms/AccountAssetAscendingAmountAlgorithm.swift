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

//   AccountAssetAscendingAmountAlgorithm.swift

import Foundation

struct AccountAssetAscendingAmountAlgorithm: AccountAssetSortingAlgorithm {
    let id: String
    let name: String

    private let currency: CurrencyProvider

    init(currency: CurrencyProvider) {
        self.currency = currency

        self.id = "cache.value.accountAssetAscendingAmountAlgorithm"
        self.name = "title-lowest-value-to-highest".localized
    }
}

extension AccountAssetAscendingAmountAlgorithm {
    func getFormula(
        asset: Asset,
        otherAsset: Asset
    ) -> Bool {
        let assetCurrencyValue = getValueInUSD(for: asset)
        let otherAssetCurrencyValue = getValueInUSD(for: otherAsset)
        if assetCurrencyValue != otherAssetCurrencyValue {
            return assetCurrencyValue < otherAssetCurrencyValue
        }

        let assetTitle =
        asset.naming.name.unwrapNonEmptyString() ??
        "title-unknown".localized
        let otherAssetTitle =
        otherAsset.naming.name.unwrapNonEmptyString() ??
        "title-unknown".localized
        if assetTitle != otherAssetTitle {
            let result = assetTitle.localizedCaseInsensitiveCompare(otherAssetTitle)
            return result == .orderedAscending
        }

        let assetID = asset.id
        let otherAssetID = otherAsset.id
        if assetID != otherAssetID {
            return assetID < otherAssetID
        }

        return false
    }
    
    private func getValueInUSD(for asset: Asset) -> Decimal {
        var valueInUSD: Decimal = 0.0

        if asset.isAlgo {
            guard let fiatCurrencyValue = try? currency.fiatValue?.unwrap() else {
                return valueInUSD
            }

            let exchanger = CurrencyExchanger(currency: fiatCurrencyValue)
            valueInUSD = (try? exchanger.exchangeAlgoToUSD(amount: asset.decimalAmount)) ?? 0
        } else {
            guard currency.primaryValue != nil else {
                return valueInUSD
            }

            valueInUSD = asset.totalUSDValue ?? 0
        }

        return valueInUSD
    }
}
