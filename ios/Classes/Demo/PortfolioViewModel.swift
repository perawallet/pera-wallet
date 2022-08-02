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

//   PortfolioViewModel.swift

import Foundation
import MacaroonUIKit

protocol PortfolioViewModel: ViewModel {
    var currencyFormatter: CurrencyFormatter? { get }
}

extension PortfolioViewModel {
    func format(
        portfolioValue: PortfolioValue?,
        currencyValue: RemoteCurrencyValue?,
        in context: CurrencyFormattingContext
    ) -> String? {
        guard
            let portfolioValue = portfolioValue,
            let currencyValue = currencyValue
        else {
            return nil
        }

        do {
            let portfolio = try portfolioValue.unwrap()
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(portfolio)

            let formatter = currencyFormatter ?? CurrencyFormatter()
            formatter.formattingContext = context
            formatter.currency =  rawCurrency
            return formatter.format(amount)
        } catch {
            return nil
        }
    }
}
