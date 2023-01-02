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

//   CurrencyExchanger.swift

import Foundation

struct CurrencyExchanger {
    let currency: RemoteCurrency

    init(
        currency: RemoteCurrency
    ) {
        self.currency = currency
    }
}

extension CurrencyExchanger {
    func exchange(
        _ portfolio: Portfolio
    ) throws -> Decimal {
        guard
            let algoValue = currency.algoValue,
            let usdValue = currency.usdValue
        else {
            throw CurrencyExchangeError.currencyFailed()
        }

        let totalValueOfAlgos = portfolio.totalAlgoValue * algoValue
        let totalValueOfAssets = portfolio.totalUSDValueOfAssets * usdValue
        return totalValueOfAlgos + totalValueOfAssets
    }

    /// <note>
    /// Returns total value if amount is nil.
    func exchange(
        _ asset: Asset,
        amount: Decimal? = nil
    ) throws -> Decimal {
        guard let usdValue = currency.usdValue else {
            throw CurrencyExchangeError.currencyFailed()
        }

        let totalUSDValue: Decimal
        if let amount = amount {
            let usdValueOfAsset = asset.usdValue ?? 0
            totalUSDValue = usdValueOfAsset * amount
        } else {
            totalUSDValue = asset.totalUSDValue ?? 0
        }

        return totalUSDValue * usdValue
    }

    func exchange(
        amount: Decimal
    ) throws -> Decimal {
        guard let usdValue = currency.usdValue else {
            throw CurrencyExchangeError.currencyFailed()
        }

        return amount * usdValue
    }

    func exchange(
        _ asset: AssetDecoration
    ) throws -> Decimal {
        guard let usdValue = currency.usdValue else {
            throw CurrencyExchangeError.currencyFailed()
        }

        let usdValueOfAsset = asset.usdValue ?? 0
        return usdValueOfAsset * usdValue
    }

    func exchangeAlgo(
        amount: Decimal
    ) throws -> Decimal {
        guard let algoValue = currency.algoValue else {
            throw CurrencyExchangeError.currencyFailed()
        }

        return amount * algoValue
    }

    func exchangeAlgoToUSD(
        amount: Decimal
    ) throws -> Decimal {
        guard let algoToUSDValue = currency.algoToUSDValue else {
            throw CurrencyExchangeError.currencyFailed()
        }

        return amount * algoToUSDValue
    }
}

enum CurrencyExchangeError: Error {
    case currencyFailed(CurrencyError? = nil)
}
