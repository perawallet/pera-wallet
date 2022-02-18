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
//   ALGPortfolioCalculator.swift

import Foundation
import MacaroonUtils

struct ALGPortfolioCalculator: PortfolioCalculator {
    func calculateCoinsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> Self.Result {
        guard
            let currencyValue = currency.value,
            let currencyPriceValue = currencyValue.priceValue
        else {
            return .failure(.currencyFailed)
        }
        
        var totalMicroAlgos: UInt64 = 0
        for account in accounts {
            if !canCalculateCoinsValue(account) {
                return .failure(.accountsFailed)
            }
            
            totalMicroAlgos += account.value.amount
        }
        
        let totalAmount = totalMicroAlgos.toAlgos * currencyPriceValue
        let algosValue = PortfolioValue(amount: totalAmount, currency: currencyValue)
        return .success(algosValue)
    }
    
    func calculateAssetsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> Self.Result {
        guard
            let currencyValue = currency.value,
            let currencyUSDValue = currencyValue.usdValue
        else {
            return .failure(.currencyFailed)
        }
        
        var totalAmount: Decimal = 0
        for account in accounts {
            if !canCalculateAssetsValue(account) {
                return .failure(.accountsFailed)
            }
            
            totalAmount += account.value.compoundAssets.reduce(0) {
                result, compoundAsset in

                let assetDetail = compoundAsset.detail
                let assetAmount = account.value
                    .amount(for: assetDetail)
                    .unwrap { $0 * currencyUSDValue * assetDetail.usdValue.unwrap(or: 0) } ?? 0
                return result + assetAmount
            }
        }
        
        let assetsValue = PortfolioValue(amount: totalAmount, currency: currencyValue)
        return .success(assetsValue)
    }
}

extension ALGPortfolioCalculator {
    private func canCalculateCoinsValue(
        _ account: AccountHandle
    ) -> Bool {
        switch account.status {
        case .inProgress,
             .ready:
            return true
        default:
            return false
        }
    }

    private func canCalculateAssetsValue(
        _ account: AccountHandle
    ) -> Bool {
        switch account.status {
        case .ready:
            return true
        default:
            return false
        }
    }
}
