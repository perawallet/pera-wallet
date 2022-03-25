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
//   PortfolioCalculator.swift

import Foundation

protocol PortfolioCalculator {
    typealias Result = Swift.Result<PortfolioValue, PortfolioValueError>
    
    func calculateCoinsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> Result
    func calculateAssetsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> Result
}

extension PortfolioCalculator {
    func calculateTotalValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> Result {
        let coinsValueResult = calculateCoinsValue(
            accounts,
            as: currency
        )
        
        switch coinsValueResult {
        case .success:
            let assetsValueResult = calculateAssetsValue(
                accounts,
                as: currency
            )
            return calculateTotalValue(
                coinsValueResult: coinsValueResult,
                assetsValueResult: assetsValueResult
            )
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func calculateTotalValue(
        coinsValueResult: Result,
        assetsValueResult: Result
    ) -> Result {
        switch (coinsValueResult, assetsValueResult) {
        case (.success(let coinsValue), .success(let assetsValue)):
            let totalValue = coinsValue + assetsValue
            return totalValue.unwrap { .success($0) } ?? .failure(.currencyFailed)
        case (.success, .failure(let error)):
            return .failure(error)
        case (.failure(let error), _):
            return .failure(error)
        }
    }
}

struct PortfolioValue {
    var formattedAmount: String {
        return amount.toCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
    }
    
    var abbreviatedFormattedAmount: String {
        return amount.abbreviatedCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
    }
    
    let amount: Decimal
    let currency: Currency
}

extension PortfolioValue {
    static func + (
        lhs: PortfolioValue,
        rhs: PortfolioValue
    ) -> PortfolioValue? {
        if lhs.currency.id != rhs.currency.id {
            return nil
        }
        
        let totalAmount = lhs.amount + rhs.amount
        return PortfolioValue(amount: totalAmount, currency: lhs.currency)
    }
}

enum PortfolioValueError: Error {
    case idle
    case currencyFailed
    case accountsFailed
}

extension Result where Success == PortfolioValue {
    var uiDescription: String {
        switch self {
        case .success(let value): return value.formattedAmount
        case .failure: return "N/A"
        }
    }
    
    var abbreviatedUiDescription: String {
        switch self {
        case .success(let value): return value.abbreviatedFormattedAmount
        case .failure: return "N/A"
        }
    }
}
