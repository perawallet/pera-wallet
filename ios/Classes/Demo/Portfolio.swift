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
//   Portfolio.swift

import Foundation
import MacaroonUIKit

struct Portfolio {
    var coinsValueResult: PortfolioCalculator.Result = .failure(.idle)
    var assetsValueResult: PortfolioCalculator.Result = .failure(.idle)
    var totalValueResult: PortfolioCalculator.Result = .failure(.idle)
    
    let accounts: [AccountHandle]
    let currency: CurrencyHandle
    let calculator: PortfolioCalculator
}

extension Portfolio {
    mutating func calculate() {
        coinsValueResult = calculator.calculateCoinsValue(
            accounts,
            as: currency
        )
        assetsValueResult = calculator.calculateAssetsValue(
            accounts,
            as: currency
        )
        totalValueResult = calculator.calculateTotalValue(
            coinsValueResult: coinsValueResult,
            assetsValueResult: assetsValueResult
        )
    }
}

struct PortfolioItem {
    let title: String
    let icon: Image?
    let valueResult: PortfolioCalculator.Result
}
